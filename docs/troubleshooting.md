# Troubleshooting Guide

## Common Issues and Solutions

### Authentication Issues

#### Problem: "Error building ARM Config: obtain subscription() from Azure CLI"
**Symptoms:**
- Terraform fails to authenticate
- Azure CLI not logged in

**Solutions:**
```bash
# Solution 1: Login via Azure CLI
az login
az account set --subscription "<subscription-id>"
az account show  # Verify correct subscription

# Solution 2: Use Service Principal
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"

# Solution 3: Clear cached credentials
rm -rf ~/.azure/
az login
```

#### Problem: "Insufficient privileges to complete the operation"
**Solutions:**
- Verify service principal has Contributor role
- Check RBAC assignments
```bash
az role assignment list --assignee <service-principal-id>
```

### State Management Issues

#### Problem: "Error acquiring the state lock"
**Symptoms:**
- Another process has locked the state
- Previous operation was interrupted

**Solutions:**
```bash
# Check lock status
az storage blob show \
  --account-name <storage-account> \
  --container-name tfstate \
  --name <layer>-<env>.tfstate \
  --query "properties.lease.status"

# Force unlock (CAUTION: ensure no other process is running)
terraform force-unlock <lock-id>

# If lock persists, manually break lease
az storage blob lease break \
  --blob-name <layer>-<env>.tfstate \
  --container-name tfstate \
  --account-name <storage-account>
```

#### Problem: "Backend configuration changed"
**Solutions:**
```bash
# Reinitialize with new backend config
terraform init -reconfigure -backend-config=backend.conf

# Or migrate state
terraform init -migrate-state
```

#### Problem: "Stored state version doesn't match running Terraform"
**Solutions:**
```bash
# Upgrade Terraform version
brew upgrade terraform  # macOS
# or download from terraform.io

# If downgrading (not recommended)
terraform state replace-provider \
  registry.terraform.io/hashicorp/azurerm \
  registry.terraform.io/hashicorp/azurerm
```

### Resource Creation Issues

#### Problem: "Resource already exists"
**Solutions:**
```bash
# Option 1: Import existing resource
terraform import <resource-type>.<name> <azure-resource-id>

# Example
terraform import azurerm_resource_group.example \
  /subscriptions/<sub-id>/resourceGroups/rg-example

# Option 2: Remove from state (doesn't delete resource)
terraform state rm <resource-address>

# Option 3: Delete existing resource (if safe)
az resource delete --ids <resource-id>
```

#### Problem: "Quota exceeded"
**Symptoms:**
- Operation could not be completed as it results in exceeding approved quota

**Solutions:**
```bash
# Check current quota
az vm list-usage --location eastus --output table

# Request quota increase
# Go to Azure Portal > Subscriptions > Usage + quotas
```

#### Problem: "Subnet is in use and cannot be deleted"
**Solutions:**
```bash
# List resources in subnet
az network vnet subnet show \
  --resource-group <rg> \
  --vnet-name <vnet> \
  --name <subnet> \
  --query "ipConfigurations[].id"

# Remove or move resources before deleting subnet
```

### Networking Issues

#### Problem: "Address space overlaps with existing network"
**Solutions:**
- Review IP address planning
- Use non-overlapping CIDR blocks
- Update terraform.tfvars with new address ranges

#### Problem: "Cannot create private endpoint - subnet has network policies enabled"
**Solutions:**
```hcl
# In subnet resource, ensure:
resource "azurerm_subnet" "example" {
  # ...
  private_endpoint_network_policies_enabled = false
}
```

#### Problem: "Service endpoint not supported"
**Solutions:**
```bash
# Check available service endpoints for region
az network vnet subnet list-available-service-endpoints \
  --location eastus
```

### Module Issues

#### Problem: "Module not found"
**Solutions:**
```bash
# Verify module path
ls -la ../../../../modules/resource-group/

# Clear module cache
rm -rf .terraform/modules/

# Reinitialize
terraform init
```

#### Problem: "Module version constraint not satisfied"
**Solutions:**
```hcl
# Update version constraint in module block
module "example" {
  source = "../../modules/example"
  # Remove or update version constraint
  # version = "~> 1.0"
}
```

### Plan/Apply Issues

#### Problem: "Changes to outputs must agree with intent"
**Solutions:**
```bash
# Run refresh
terraform refresh -var-file=terraform.tfvars

# Or force refresh during plan
terraform plan -refresh=true -var-file=terraform.tfvars
```

#### Problem: "Timeout while waiting for resource"
**Solutions:**
```hcl
# Increase timeout in resource
resource "azurerm_kubernetes_cluster" "example" {
  # ...
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
```

#### Problem: "Cycles in dependency graph"
**Solutions:**
- Review depends_on relationships
- Remove circular dependencies
- Use data sources instead of direct references
- Split resources into separate layers

### AKS-Specific Issues

#### Problem: "AKS cluster creation fails"
**Common causes and solutions:**

1. **Insufficient subnet size**
```hcl
# Ensure subnet is large enough
# For Azure CNI: nodes * max_pods + buffer
# Minimum /24 for small clusters, /22 for production
```

2. **Service principal permissions**
```bash
# Grant Network Contributor to AKS subnet
az role assignment create \
  --assignee <sp-id> \
  --role "Network Contributor" \
  --scope <subnet-id>
```

3. **Service CIDR conflicts**
```hcl
# Ensure service_cidr doesn't overlap with VNet
service_cidr = "172.16.0.0/16"  # Non-overlapping range
```

### Database Issues

#### Problem: "Private endpoint connection failed"
**Solutions:**
```bash
# Verify private DNS zone is linked to VNet
az network private-dns link vnet list \
  --resource-group <rg> \
  --zone-name privatelink.database.windows.net

# Create link if missing
az network private-dns link vnet create \
  --resource-group <rg> \
  --zone-name privatelink.database.windows.net \
  --name <link-name> \
  --virtual-network <vnet-id> \
  --registration-enabled false
```

### Performance Issues

#### Problem: "Terraform plan takes too long"
**Solutions:**
```bash
# Use targeted plans for specific resources
terraform plan -target=module.specific_module

# Disable refresh
terraform plan -refresh=false

# Reduce parallelism
terraform apply -parallelism=5
```

#### Problem: "State file is very large"
**Solutions:**
```bash
# Split into multiple state files (by layer)
# This is why we use separate layers!

# Or remove old resources from state
terraform state rm 'module.old_module'
```

### Debugging Techniques

#### Enable Debug Logging
```bash
# Enable detailed logs
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log

# Run terraform command
terraform plan

# Disable after debugging
unset TF_LOG
unset TF_LOG_PATH
```

#### Validate Configuration
```bash
# Check syntax
terraform validate

# Format code
terraform fmt -recursive

# Use linting tools
tflint --init
tflint

# Check for security issues
tfsec .
checkov -d .
```

#### Inspect State
```bash
# List all resources
terraform state list

# Show resource details
terraform state show <resource-address>

# View outputs
terraform output

# Pull state for inspection
terraform state pull > state.json
```

### Recovery Procedures

#### Complete State Loss
```bash
# If state is lost but resources exist:
# 1. Restore from backup
az storage blob download \
  --account-name <sa> \
  --container-name tfstate \
  --name <file>.tfstate \
  --version-id <version> \
  --file terraform.tfstate.restored

# 2. Or import all resources (tedious)
terraform import <type>.<name> <azure-id>

# 3. Or recreate state from scratch
# Write import script to bulk import resources
```

#### Corrupted State
```bash
# Restore previous version
az storage blob list \
  --account-name <sa> \
  --container-name tfstate \
  --prefix <file>.tfstate \
  --show-next-marker

# Download specific version
az storage blob download \
  --version-id <previous-version-id> \
  --name <file>.tfstate \
  --container-name tfstate \
  --account-name <sa> \
  --file terraform.tfstate.restored
```

## Prevention Best Practices

1. **Always backup state before major changes**
```bash
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate
```

2. **Use workspaces or separate backends for environments**

3. **Enable state locking** (already configured with Azure Storage)

4. **Regular state file versioning** (enabled in Azure Storage)

5. **Use version constraints**
```hcl
terraform {
  required_version = "~> 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
```

6. **Run terraform plan before every apply**

7. **Use CI/CD pipelines for production deployments**

8. **Implement proper access controls**
- Limit who can run terraform apply in production
- Use service principals with minimal required permissions
- Enable audit logging

9. **Monitor resource changes**
- Set up Azure Activity Log alerts
- Review changes in Azure Portal
- Use Azure Policy for compliance

10. **Document everything**
- Keep runbooks updated
- Document all infrastructure changes
- Maintain architecture diagrams

## Getting Help

### Internal Resources
- Platform Engineering Team: platform-team@company.com
- Documentation: See /docs directory
- Architecture Diagrams: See docs/architecture.md

### External Resources
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Documentation](https://docs.microsoft.com/azure)
- [Terraform Community Forum](https://discuss.hashicorp.com/)
- [Azure Support](https://azure.microsoft.com/support/)

### Emergency Contacts
- On-call SRE: [Your escalation process]
- Azure Support Case: [How to open support case]
- Security Incidents: [Security team contact]

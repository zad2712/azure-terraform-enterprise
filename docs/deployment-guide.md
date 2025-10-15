# Deployment Guide

## Prerequisites

### Required Tools

- **Terraform**: >= 1.5.0
- **Azure CLI**: >= 2.50.0
- **Git**: For version control
- **jq**: For JSON parsing (optional but recommended)

### Azure Requirements

- Azure subscription with Owner or Contributor rights
- Azure AD permissions for Service Principal creation
- Resource providers registered
- Sufficient quota for resources

## Initial Setup

### 1. Azure Authentication

#### Option A: Service Principal (Recommended for CI/CD)

```bash
# Create a service principal
az ad sp create-for-rbac --name "terraform-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/<subscription-id>"

# Output (save these securely):
# {
#   "appId": "<client-id>",
#   "password": "<client-secret>",
#   "tenant": "<tenant-id>"
# }

# Set environment variables
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

#### Option B: Azure CLI (For Development)

```bash
az login
az account set --subscription "<subscription-id>"
```

### 2. Backend Storage Setup

Create a storage account for Terraform state:

```bash
#!/bin/bash
# setup-backend.sh

RESOURCE_GROUP="rg-terraform-state"
LOCATION="eastus"
STORAGE_ACCOUNT="sttfstate${RANDOM}"
CONTAINER_NAME="tfstate"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Create container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

# Enable versioning
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --enable-versioning true

echo "Backend storage account: $STORAGE_ACCOUNT"
```

### 3. Configure Backend for Each Environment

Update `backend.conf` in each environment with:

```hcl
storage_account_name = "<your-storage-account>"
container_name       = "tfstate"
key                  = "<layer>-<environment>.tfstate"  # e.g., networking-dev.tfstate
```

## Deployment Workflow

### Step 1: Deploy Networking Layer

Networking must be deployed first as all other layers depend on it.

```bash
# Navigate to networking dev environment
cd layers/networking/environments/dev

# Initialize Terraform
terraform init -backend-config=backend.conf

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan deployment
terraform plan -var-file=terraform.tfvars -out=tfplan

# Review the plan carefully
# Apply the plan
terraform apply tfplan

# Save outputs for other layers
terraform output -json > networking-outputs.json
```

### Step 2: Deploy Security Layer

```bash
cd ../../security/environments/dev

terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

### Step 3: Deploy Database Layer

```bash
cd ../../database/environments/dev
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

### Step 4: Deploy Storage Layer

```bash
cd ../../storage/environments/dev
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

### Step 5: Deploy Compute Layer

```bash
cd ../../compute/environments/dev
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

### Step 6: Deploy DNS Layer

```bash
cd ../../dns/environments/dev
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

### Step 7: Deploy Monitoring Layer

```bash
cd ../../monitoring/environments/dev
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

## Environment Promotion

After successful deployment and testing in dev, promote to higher environments:

```bash
# Example: Promoting to QA
cd layers/networking/environments/qa
terraform init -backend-config=backend.conf
terraform plan -var-file=terraform.tfvars
# Review differences carefully
terraform apply -var-file=terraform.tfvars
```

## State Management

### Viewing State

```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show <resource-address>

# Pull state to local file
terraform state pull > terraform.tfstate.backup
```

### State Operations (Use with Caution)

```bash
# Move resource in state
terraform state mv <source> <destination>

# Remove resource from state (doesn't delete resource)
terraform state rm <resource-address>

# Import existing resource
terraform import <resource-address> <azure-resource-id>
```

1. **Always use terraform plan before apply**
2. **Never commit .tfstate files to git**
3. **Use -out parameter to save plans**
4. **Review plans carefully before applying**
5. **Use workspaces or separate backends for environments**
6. **Tag all resources consistently**
7. **Document all infrastructure changes**
8. **Use version constraints for providers and modules**
9. **Implement proper state locking**
10. **Regular state backups**

## CI/CD Pipeline Integration

### GitHub Actions Example

```yaml
name: Terraform Deploy
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        run: terraform init -backend-config=backend.conf
        working-directory: layers/${{ matrix.layer }}/environments/${{ matrix.env }}
      
      - name: Terraform Plan
        run: terraform plan -var-file=terraform.tfvars
        working-directory: layers/${{ matrix.layer }}/environments/${{ matrix.env }}
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve -var-file=terraform.tfvars
        working-directory: layers/${{ matrix.layer }}/environments/${{ matrix.env }}
```

## Security Considerations

- Store service principal credentials in GitHub Secrets or Azure Key Vault
- Use managed identities in Azure DevOps or GitHub runners
- Enable MFA for all administrative accounts
- Rotate secrets regularly
- Audit all infrastructure changes
- Use private endpoints for state storage

## Monitoring Deployments

Check deployment status in Azure Portal:
- Resource Groups
- Activity Log
- Deployment History

Monitor Terraform operations:
- State file versions in Storage Account
- Lock status
- Last modified timestamp

## Rollback Procedures

If deployment fails:

```bash
# Option 1: Revert to previous state
terraform state pull > current.tfstate
# Restore previous version from Azure Storage
az storage blob download --account-name <sa> --container-name tfstate \
  --name <layer>-<env>.tfstate --version-id <previous-version> \
  --file terraform.tfstate

# Option 2: Destroy failed resources
terraform destroy -target=<resource-address>

# Option 3: Complete rollback
terraform destroy -var-file=terraform.tfvars
# Then redeploy previous working version
```

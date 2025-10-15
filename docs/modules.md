# Module Documentation

## Overview

This directory contains reusable Terraform modules for Azure infrastructure. Each module is designed following best practices and can be independently versioned and tested.

## Module Categories

### Core Infrastructure
- **resource-group**: Standard Azure resource groups with tagging and locks

### Networking Modules
- **networking/vnet**: Virtual networks with diagnostic settings
- **networking/subnet**: Subnets with service delegation
- **networking/nsg**: Network security groups with custom rules
- **networking/application-gateway**: Layer 7 load balancer with WAF
- **networking/load-balancer**: Layer 4 load balancer
- **networking/private-endpoint**: Private endpoints for PaaS services
- **networking/nat-gateway**: Outbound internet connectivity

### Compute Modules
- **compute/virtual-machine**: Virtual machines with managed disks
- **compute/vmss**: Virtual machine scale sets with auto-scaling
- **compute/aks**: Azure Kubernetes Service clusters
- **compute/app-service**: Platform-as-a-Service web hosting
- **compute/function-app**: Serverless compute
- **compute/container-instances**: Short-lived container workloads

### Database Modules
- **database/sql-database**: Azure SQL Database with elastic pools
- **database/postgresql**: Azure Database for PostgreSQL Flexible Server
- **database/mysql**: Azure Database for MySQL Flexible Server
- **database/cosmos-db**: Globally distributed NoSQL database
- **database/redis-cache**: In-memory caching service

### Storage Modules
- **storage/storage-account**: Blob, file, queue, and table storage
- **storage/file-share**: SMB file shares
- **storage/blob-container**: Blob container with lifecycle policies

### Security Modules
- **security/key-vault**: Secrets and certificate management
- **security/managed-identity**: User and system-assigned identities
- **security/private-dns-zone**: Private DNS zones for endpoints

### Monitoring Modules
- **monitoring/log-analytics**: Centralized logging workspace
- **monitoring/application-insights**: Application performance monitoring
- **monitoring/monitor-action-group**: Alert notification groups

### DNS Modules
- **dns/dns-zone**: Public and private DNS zones with records

## Module Standards

All modules follow these standards:

### File Structure
```
module-name/
├── main.tf          # Primary resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── README.md        # Module documentation
├── versions.tf      # Terraform and provider versions (optional)
└── examples/        # Usage examples (optional)
```

### Naming Conventions
- Resources: Use descriptive names with proper prefixes
- Variables: Use snake_case
- Outputs: Use snake_case
- Tags: Use PascalCase for keys

### Required Inputs
Most modules require:
- `name`: Resource name
- `location`: Azure region
- `resource_group_name`: Parent resource group
- `tags`: Resource tags

### Common Features
- **Validation**: Input validation where applicable
- **Defaults**: Sensible defaults for optional parameters
- **Tagging**: Consistent tagging support
- **Diagnostics**: Monitoring and logging capabilities
- **Security**: Private endpoints, encryption, RBAC
- **High Availability**: Zone redundancy options

## Usage Patterns

### Basic Module Usage
```hcl
module "example" {
  source = "../../modules/resource-type/module-name"

  name                = "resource-name"
  location            = "eastus"
  resource_group_name = "rg-example"
  
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### With Remote State
```hcl
data "terraform_remote_state" "networking" {
  backend = "azurerm"
  config = {
    storage_account_name = "mystorageaccount"
    container_name       = "tfstate"
    key                  = "networking-dev.tfstate"
    resource_group_name  = "rg-terraform-state"
  }
}

module "app_service" {
  source = "../../modules/compute/app-service"

  # Use outputs from remote state
  subnet_id = data.terraform_remote_state.networking.outputs.subnet_app_service_id
}
```

## Module Development Guidelines

### Creating New Modules

1. **Plan the module interface**
   - Define required and optional variables
   - Plan output values
   - Consider dependencies

2. **Implement the module**
   - Follow the standard file structure
   - Add input validation
   - Include diagnostic settings
   - Implement tagging

3. **Document the module**
   - Write comprehensive README
   - Include usage examples
   - Document all inputs and outputs

4. **Test the module**
   - Test with different configurations
   - Validate in multiple environments
   - Check for idempotency

### Module Versioning

For production use, consider:
- Using module registry (Terraform Cloud/Enterprise)
- Git tags for version control
- Semantic versioning (v1.0.0)

Example:
```hcl
module "example" {
  source  = "git::https://github.com/org/terraform-modules.git//azure/compute/aks?ref=v1.0.0"
  # ...
}
```

## Module Dependencies

### Network Layer Dependencies
```
resource-group
└── networking/vnet
    └── networking/subnet
        └── networking/nsg
```

### Compute Layer Dependencies
```
resource-group
├── networking/* (from networking layer)
└── security/key-vault (from security layer)
    └── compute/aks
```

### Database Layer Dependencies
```
resource-group
├── networking/* (from networking layer)
├── security/key-vault (from security layer)
└── security/private-dns-zone
    └── database/*
```

## Best Practices

1. **Keep modules focused**: One module = one resource type
2. **Use data sources**: Reference existing resources
3. **Implement lifecycle rules**: Prevent accidental deletions
4. **Enable diagnostics**: All modules should support logging
5. **Use private endpoints**: For PaaS services
6. **Validate inputs**: Use variable validation blocks
7. **Document everything**: Comprehensive READMEs
8. **Test thoroughly**: Multiple configurations and environments
9. **Version carefully**: Use semantic versioning
10. **Tag consistently**: All resources should have standard tags

## Troubleshooting Common Issues

### State Lock Conflicts
```bash
# Check who has the lock
az storage blob show --account-name <sa> --container-name tfstate \
  --name <layer>-<env>.tfstate

# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

### Module Not Found
- Verify source path is correct relative to calling module
- Check if module directory exists
- Ensure no typos in module names

### Cyclic Dependencies
- Review module dependencies
- Consider using data sources instead of direct references
- Split into separate layers if needed

## Additional Resources

- [Terraform Module Best Practices](https://www.terraform.io/docs/modules/index.html)
- [Azure Naming Conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework/)

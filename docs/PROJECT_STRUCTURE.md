# Complete Project Structure

```
terraform-azure-enterprise/
│
├── README.md                          # Main project documentation
├── .gitignore                         # Git ignore rules
├── Makefile                           # Common operations automation
│
├── docs/                              # Comprehensive documentation
│   ├── architecture.md                # Architecture and design decisions
│   ├── deployment-guide.md            # Step-by-step deployment instructions
│   ├── disaster-recovery.md           # DR procedures and runbooks
│   ├── modules.md                     # Module documentation and standards
│   └── troubleshooting.md             # Common issues and solutions
│
├── scripts/                           # Automation and helper scripts
│   ├── generate-configs.sh            # Generate environment configs
│   ├── setup-backend.sh               # Initialize Azure backend storage
│   ├── validate-all.sh                # Validate all Terraform code
│   └── cleanup-old-states.sh          # Cleanup old state versions
│
├── modules/                           # Reusable Terraform modules
│   │
│   ├── resource-group/                # Resource group with locks
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── networking/                    # Networking modules
│   │   ├── vnet/                      # Virtual Network
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── README.md
│   │   ├── subnet/                    # Subnets
│   │   ├── nsg/                       # Network Security Groups
│   │   ├── application-gateway/       # Application Gateway + WAF
│   │   ├── load-balancer/             # Azure Load Balancer
│   │   ├── private-endpoint/          # Private Endpoints
│   │   └── nat-gateway/               # NAT Gateway
│   │
│   ├── compute/                       # Compute modules
│   │   ├── virtual-machine/           # Virtual Machines
│   │   ├── vmss/                      # VM Scale Sets
│   │   ├── aks/                       # Azure Kubernetes Service
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── README.md
│   │   ├── app-service/               # App Services
│   │   ├── function-app/              # Azure Functions
│   │   └── container-instances/       # Container Instances
│   │
│   ├── database/                      # Database modules
│   │   ├── sql-database/              # Azure SQL Database
│   │   ├── postgresql/                # PostgreSQL Flexible Server
│   │   ├── mysql/                     # MySQL Flexible Server
│   │   ├── cosmos-db/                 # Cosmos DB
│   │   └── redis-cache/               # Redis Cache
│   │
│   ├── storage/                       # Storage modules
│   │   ├── storage-account/           # Storage Accounts
│   │   ├── file-share/                # Azure Files
│   │   └── blob-container/            # Blob Containers
│   │
│   ├── security/                      # Security modules
│   │   ├── key-vault/                 # Key Vault
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── README.md
│   │   ├── managed-identity/          # Managed Identities
│   │   └── private-dns-zone/          # Private DNS Zones
│   │
│   ├── monitoring/                    # Monitoring modules
│   │   ├── log-analytics/             # Log Analytics Workspace
│   │   ├── application-insights/      # Application Insights
│   │   └── monitor-action-group/      # Action Groups
│   │
│   └── dns/                           # DNS modules
│       └── dns-zone/                  # DNS Zones and Records
│
└── layers/                            # Infrastructure layers
    │
    ├── networking/                    # Network infrastructure
    │   └── environments/
    │       ├── dev/
    │       │   ├── main.tf            # Main Terraform configuration
    │       │   ├── variables.tf       # Variable definitions
    │       │   ├── outputs.tf         # Output values
    │       │   ├── backend.conf       # Backend configuration
    │       │   └── terraform.tfvars   # Environment-specific values
    │       ├── qa/
    │       │   ├── main.tf
    │       │   ├── variables.tf
    │       │   ├── outputs.tf
    │       │   ├── backend.conf
    │       │   └── terraform.tfvars
    │       ├── uat/
    │       │   ├── main.tf
    │       │   ├── variables.tf
    │       │   ├── outputs.tf
    │       │   ├── backend.conf
    │       │   └── terraform.tfvars
    │       └── prod/
    │           ├── main.tf
    │           ├── variables.tf
    │           ├── outputs.tf
    │           ├── backend.conf
    │           └── terraform.tfvars
    │
    ├── security/                      # Security layer
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    ├── database/                      # Database layer
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    ├── storage/                       # Storage layer
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    ├── compute/                       # Compute layer
    │   └── environments/
    │       ├── dev/
    │       │   ├── main.tf
    │       │   ├── variables.tf
    │       │   ├── outputs.tf
    │       │   ├── backend.conf
    │       │   └── terraform.tfvars
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    ├── dns/                           # DNS layer
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    └── monitoring/                    # Monitoring layer
        └── environments/
            ├── dev/
            ├── qa/
            ├── uat/
            └── prod/
```

## Directory Purpose

### Root Level Files
- **README.md**: Project overview, quick start, and deployment order
- **.gitignore**: Excludes sensitive files and Terraform artifacts
- **Makefile**: Common operations (init, plan, apply, destroy)

### Documentation (/docs)
Comprehensive documentation for architecture, deployment, disaster recovery, and troubleshooting.

### Scripts (/scripts)
Automation scripts for common tasks:
- Backend storage setup
- Configuration generation
- Validation and testing
- Cleanup and maintenance

### Modules (/modules)
Reusable, tested Terraform modules organized by Azure service category:
- **resource-group**: Foundation for all resources
- **networking**: VNets, subnets, NSGs, gateways
- **compute**: VMs, AKS, App Services, Functions
- **database**: SQL, PostgreSQL, MySQL, Cosmos DB, Redis
- **storage**: Storage accounts, file shares, blob containers
- **security**: Key Vault, managed identities, private DNS
- **monitoring**: Log Analytics, Application Insights, alerts
- **dns**: Public and private DNS zones

### Layers (/layers)
Infrastructure organized by logical layers for proper dependency management:

1. **networking**: Foundation - VNets, subnets, NSGs, routing
2. **security**: Key Vaults, identities, private DNS zones
3. **database**: Database services with private endpoints
4. **storage**: Storage accounts and containers
5. **compute**: AKS, VMs, App Services
6. **dns**: DNS zones and records
7. **monitoring**: Observability and alerting

Each layer contains:
- **environments/**: Separate directories for dev, qa, uat, prod
- **main.tf**: Primary resource definitions and module calls
- **variables.tf**: Input variable definitions
- **outputs.tf**: Output values for cross-layer dependencies
- **backend.conf**: Remote state configuration
- **terraform.tfvars**: Environment-specific variable values

## File Naming Conventions

### Resource Naming
Follow Azure naming conventions with prefixes:
- `rg-`: Resource groups
- `vnet-`: Virtual networks
- `snet-`: Subnets
- `nsg-`: Network security groups
- `aks-`: AKS clusters
- `kv-`: Key vaults
- `st`: Storage accounts (no hyphens, 3-24 chars)
- `sql-`: SQL servers
- `law-`: Log Analytics workspaces
- `appi-`: Application Insights

### Format
```
<prefix>-<project>-<environment>-<region>-<instance>

Examples:
- rg-myapp-prod-eastus-01
- vnet-myapp-dev-westus-01
- aks-myapp-prod-eastus-main
- kv-myapp-prod-eus-01
```

## State Management

### Backend Configuration
- **Storage Location**: Azure Storage Account (geo-redundant)
- **Container**: tfstate
- **Key Format**: `<layer>-<environment>.tfstate`
- **Locking**: Enabled via Azure Storage blob lease
- **Versioning**: Enabled for state recovery

### State Organization
Each layer + environment combination has its own state file:
```
tfstate/
├── networking-dev.tfstate
├── networking-qa.tfstate
├── networking-uat.tfstate
├── networking-prod.tfstate
├── security-dev.tfstate
├── security-qa.tfstate
...
```

## Deployment Flow

```
1. networking (dev) → 2. security (dev) → 3. database (dev) → 4. storage (dev) → 
5. compute (dev) → 6. dns (dev) → 7. monitoring (dev)

Then repeat for qa, uat, and finally prod
```

## Variable Precedence

1. Command line flags: `-var` and `-var-file`
2. `terraform.tfvars` file
3. Environment variables: `TF_VAR_*`
4. Default values in variables.tf

## Module Usage Pattern

```hcl
# In layer main.tf
module "resource_name" {
  source = "../../../../modules/category/module-name"
  
  # Required parameters
  name                = "resource-name"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Optional parameters with defaults
  tags = local.common_tags
  
  depends_on = [module.dependency]
}

# Reference outputs
output "resource_id" {
  value = module.resource_name.id
}
```

## Cross-Layer Dependencies

Use Terraform remote state data sources:

```hcl
data "terraform_remote_state" "networking" {
  backend = "azurerm"
  
  config = {
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstate"
    key                  = "networking-${var.environment}.tfstate"
    resource_group_name  = "rg-terraform-state"
  }
}

# Use outputs from networking layer
subnet_id = data.terraform_remote_state.networking.outputs.subnet_aks_system_id
```

## Tagging Strategy

All resources must have these tags:

```hcl
tags = {
  Environment        = "dev|qa|uat|prod"
  ManagedBy          = "terraform"
  Project            = "<project-name>"
  CostCenter         = "<cost-center>"
  Owner              = "<team-name>"
  Criticality        = "low|medium|high|critical"
  DataClassification = "public|internal|confidential|restricted"
  DeploymentDate     = "<timestamp>"
  Layer              = "networking|security|compute|etc"
}
```

## Security Considerations

### Sensitive Data
Never commit to Git:
- `*.tfstate` files
- `*.tfvars` with sensitive values
- Private keys, certificates
- Service principal credentials
- Passwords or secrets

### Access Control
- Service principal: Minimum required permissions
- State storage: RBAC with role assignments
- Key Vault: RBAC for secret access
- Resource groups: Contributor for Terraform SP

### Network Security
- Private endpoints for all PaaS services
- NSGs with deny-by-default rules
- No public IP addresses unless required
- VNet integration for App Services/Functions

## Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Use workspaces or separate backends for environments**
3. **Enable state locking**
4. **Implement proper dependency management**
5. **Use version constraints for providers**
6. **Tag all resources consistently**
7. **Document all changes**
8. **Regular backup verification**
9. **Automated testing in CI/CD**
10. **Peer review for infrastructure changes**

## Quick Commands

```bash
# Initialize
cd layers/<layer>/environments/<env>
terraform init -backend-config=backend.conf

# Validate
terraform validate
terraform fmt -recursive

# Plan
terraform plan -var-file=terraform.tfvars -out=tfplan

# Apply
terraform apply tfplan

# Destroy (use with caution!)
terraform destroy -var-file=terraform.tfvars

# Output
terraform output
terraform output -json > outputs.json

# State operations
terraform state list
terraform state show <resource>
```

---

**Document Version**: 1.0  
**Last Updated**: 2025-10-05  
**Maintained By**: Platform Engineering Team

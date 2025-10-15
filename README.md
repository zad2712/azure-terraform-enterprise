# Enterprise-Grade Azure Infrastructure with Terraform

## 🏗️ Architecture Overview

This repository contains a production-ready, enterprise-grade Terraform infrastructure designed for Azure following the Well-Architected Framework principles and industry best practices.

### Design Principles

- **Modularity**: Reusable, composable modules
- **Environment Isolation**: Separate state files per environment and layer
- **Security First**: Zero-trust networking, encryption at rest and in transit
- **High Availability**: Multi-region capable, zone-redundant resources
- **Observability**: Comprehensive monitoring and logging
- **Cost Optimization**: Resource tagging, rightsizing, and auto-scaling
- **Operational Excellence**: GitOps ready, IaC best practices

## 📁 Repository Structure

```
terraform-azure-enterprise/
│
├── README.md                          # This file
├── START_HERE.md                      # Quick start guide (read this first!)
├── GETTING_STARTED.md                 # Comprehensive getting started guide
├── PROJECT_SUMMARY.md                 # Complete project summary
├── STRUCTURE_CORRECTED.md             # Structure explanation
├── NETWORKING_LAYER_FIXED.md          # Networking layer documentation
├── Makefile                           # Automation commands (25+ commands)
├── .gitignore                         # Git ignore rules
│
├── docs/                              # Comprehensive documentation
│   ├── architecture.md                # Architecture decisions (150+ lines)
│   ├── deployment-guide.md            # Step-by-step deployment (200+ lines)
│   ├── disaster-recovery.md           # DR procedures (477 lines)
│   ├── modules.md                     # Module documentation (236 lines)
│   ├── troubleshooting.md             # Common issues (436 lines)
│   └── PROJECT_STRUCTURE.md           # Complete structure reference
│
├── scripts/                           # Automation and helper scripts
│   ├── generate-backend-configs.sh    # Generate all backend.conf files
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
│   │   │   └── outputs.tf
│   │   ├── subnet/                    # Subnets with delegation
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── nsg/                       # Network Security Groups
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── nsg-association/           # NSG to Subnet association
│   │   ├── route-table/               # Route Tables
│   │   ├── route-table-association/   # Route Table to Subnet association
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
│   │   │   └── outputs.tf
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
│   │   │   └── outputs.tf
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
└── layers/                            # Infrastructure layers (deployment units)
    │
    ├── networking/                    # Network infrastructure layer
    │   ├── main.tf                    # Calls modules from /modules (NO resources)
    │   ├── variables.tf               # Variable definitions
    │   ├── outputs.tf                 # Output values
    │   ├── locals.tf                  # Environment-specific logic
    │   └── environments/
    │       ├── dev/
    │       │   ├── backend.conf       # Backend configuration
    │       │   └── terraform.tfvars   # Dev environment values
    │       ├── qa/
    │       │   ├── backend.conf
    │       │   └── terraform.tfvars
    │       ├── uat/
    │       │   ├── backend.conf
    │       │   └── terraform.tfvars
    │       └── prod/
    │           ├── backend.conf
    │           └── terraform.tfvars
    │
    ├── security/                      # Security layer
    │   ├── main.tf                    # Calls modules from /modules (NO resources)
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── locals.tf
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    ├── database/                      # Database layer
    │   ├── main.tf                    # Calls modules from /modules (NO resources)
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── locals.tf
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    ├── storage/                       # Storage layer
    │   ├── main.tf                    # Calls modules from /modules (NO resources)
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── locals.tf
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    ├── compute/                       # Compute layer
    │   ├── main.tf                    # Calls modules from /modules (NO resources)
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── locals.tf
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    ├── dns/                           # DNS layer
    │   ├── main.tf                    # Calls modules from /modules (NO resources)
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── locals.tf
    │   └── environments/
    │       ├── dev/
    │       ├── qa/
    │       ├── uat/
    │       └── prod/
    │
    └── monitoring/                    # Monitoring layer
        ├── main.tf                    # Calls modules from /modules (NO resources)
        ├── variables.tf
        ├── outputs.tf
        ├── locals.tf
        └── environments/
            ├── dev/
            ├── qa/
            ├── uat/
            └── prod/
```

### Key Structure Concepts

#### Root Module Pattern (Layers)
Each layer is a **root module** that:
- Contains `main.tf` that **ONLY calls modules** from `/modules`
- Contains `variables.tf`, `outputs.tf`, and `locals.tf` at the layer root
- Has an `environments/` directory with **ONLY** `backend.conf` and `terraform.tfvars` per environment
- **Never creates resources directly** - all resources are created by child modules

#### Child Modules (Modules)
Located in `/modules`, these are reusable components that:
- Contain the actual `resource` blocks
- Are called by layer root modules
- Can be versioned and shared
- Follow single responsibility principle

#### Environment Configuration
Each environment folder contains exactly 2 files:
- `backend.conf` - Remote state configuration
- `terraform.tfvars` - Environment-specific variable values

#### Working Directory
Always run Terraform commands from the **layer root**, not from environment folders:
```bash
cd layers/networking/
terraform init -backend-config=environments/dev/backend.conf
terraform plan -var-file=environments/dev/terraform.tfvars
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.5.0
- Azure CLI >= 2.50.0
- Azure subscription with appropriate permissions
- Azure Storage Account for state management
- Service Principal or Managed Identity

### Initial Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd terraform-azure-enterprise
```

2. **Configure Azure credentials**
```bash
az login
az account set --subscription "<subscription-id>"
```

3. **Create backend storage (one-time setup)**
```bash
chmod +x scripts/*.sh
./scripts/generate-backend-configs.sh YOUR_STORAGE_ACCOUNT_NAME
```

4. **Initialize and deploy a layer**
```bash
# Navigate to layer root (not environment!)
cd layers/networking

# Initialize Terraform with backend configuration
terraform init -backend-config=environments/dev/backend.conf

# Review the plan
terraform plan -var-file=environments/dev/terraform.tfvars

# Apply changes
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Using the Makefile (Recommended)

```bash
# Initialize a layer
make init LAYER=networking ENV=dev

# Plan changes
make plan LAYER=networking ENV=dev

# Apply changes
make apply LAYER=networking ENV=dev

# Deploy entire environment (all layers in order)
make deploy-dev

# See all commands
make help
```

## 📋 Deployment Order

Infrastructure must be deployed in the following order due to dependencies:

1. **Networking Layer** - VNets, Subnets, NSGs, Route Tables
2. **Security Layer** - Key Vaults, Managed Identities, Private DNS Zones
3. **Database Layer** - SQL Databases, Cosmos DB, Redis Cache
4. **Storage Layer** - Storage Accounts, Blob Containers, File Shares
5. **Compute Layer** - VMs, VMSS, AKS, App Services
6. **DNS Layer** - DNS Zones, Records
7. **Monitoring Layer** - Log Analytics, Application Insights, Alerts

## 🔐 Security Best Practices

- **State Files**: Encrypted at rest in Azure Storage with private endpoints
- **Secrets Management**: All secrets stored in Azure Key Vault
- **Network Security**: Private endpoints, NSGs, and Azure Firewall
- **Identity**: Managed Identities used wherever possible
- **Encryption**: TLS 1.2+ for all communications, encryption at rest for all storage
- **Access Control**: RBAC with least privilege principle
- **Audit Logging**: All operations logged to Log Analytics

## 🏷️ Tagging Strategy

All resources are tagged with:
- `Environment`: dev, qa, uat, prod
- `ManagedBy`: terraform
- `Project`: <project-name>
- `CostCenter`: <cost-center>
- `Owner`: <team-name>
- `Criticality`: low, medium, high, critical
- `DataClassification`: public, internal, confidential, restricted

## 📊 Monitoring and Observability

- **Centralized Logging**: All logs aggregated in Log Analytics Workspace
- **Application Performance**: Application Insights for application monitoring
- **Infrastructure Metrics**: Azure Monitor for resource metrics
- **Alerting**: Action groups configured for critical alerts
- **Dashboards**: Pre-configured Azure dashboards per environment

## 💰 Cost Management

- Resource tagging for cost allocation
- Auto-scaling configurations
- Scheduled start/stop for non-production resources
- Budget alerts configured per environment
- Regular cost optimization reviews

## 🔄 CI/CD Integration

This infrastructure supports GitOps workflows:
- Branch protection for production
- Automated terraform plan on PR
- Manual approval for production deployments
- State locking to prevent concurrent modifications
- Automated testing with terraform validate and tflint

## 📚 Documentation

Detailed documentation available in `/docs`:
- [Architecture Diagrams](./docs/architecture.md) - Design decisions and patterns
- [Module Documentation](./docs/modules.md) - Module usage and standards
- [Deployment Guide](./docs/deployment-guide.md) - Step-by-step procedures
- [Disaster Recovery](./docs/disaster-recovery.md) - DR runbooks and procedures
- [Troubleshooting](./docs/troubleshooting.md) - Common issues and solutions
- [Project Structure](./docs/PROJECT_STRUCTURE.md) - Complete structure reference

**Start Here**: Read [START_HERE.md](./START_HERE.md) for a quick start guide!

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run terraform fmt and terraform validate
4. Submit a pull request
5. Ensure all checks pass

## 📞 Support

For issues and questions:
- Create an issue in this repository
- Contact the platform team
- Refer to the troubleshooting guide

## 📝 License

[Your License Here]

---

**Maintained by**: Platform Engineering Team  
**Last Updated**: 2025-10-06  
**Version**: 1.0.0

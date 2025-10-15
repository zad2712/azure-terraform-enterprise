# Copilot Instructions - Azure Terraform Enterprise

## Architecture Overview

This is a **layered, enterprise-grade Terraform infrastructure** for Azure with strict separation of concerns:

- **7 Infrastructure Layers**: `networking` → `security` → `storage` → `database` → `compute` → `monitoring` → `dns` (deployed in dependency order)
- **4 Environments**: `dev`, `qa`, `uat`, `prod` (each with isolated state files)
- **Modular Design**: All resources defined as reusable modules in `/modules/`, consumed by layers in `/layers/`

## Critical Patterns

### Layer Structure (Essential)
- **Layers NEVER contain direct resources** - only module calls
- Each layer: `main.tf` (module calls), `variables.tf`, `outputs.tf`, `locals.tf`, `providers.tf`
- Environment configs: `layers/{layer}/environments/{env}/terraform.tfvars` + `backend.conf`
- **Dependency chain**: Always deploy layers in order - networking foundation first

### Backend State Management
- Each layer+environment = separate state file (e.g., `networking-dev.tfstate`)
- Backend configs in `layers/{layer}/environments/{env}/backend.conf`
- State files stored in Azure Storage with resource group `rg-terraform-state`
- **Never share state between layers** - use data sources for cross-layer references

### Makefile Workflow (Primary Interface)
```bash
# Standard deployment pattern
make init LAYER=networking ENV=dev
make plan LAYER=networking ENV=dev  
make apply LAYER=networking ENV=dev

# Full environment deployment
for layer in networking security storage database compute monitoring; do
  make apply LAYER=$layer ENV=dev
done
```

## Development Workflows

### Adding New Resources
1. **Create/update module** in `/modules/{category}/{resource}/`
2. **Call module** from appropriate layer's `main.tf`
3. **Add variables** to layer's `variables.tf` and environment `.tfvars`
4. **Test locally** using Makefile commands
5. **Use GitHub Actions** for automated deployment

### GitHub Actions Integration
- **PR Automation**: `terraform-pr-automation.yml` - auto-plans on PRs
- **Deployment**: `terraform-deploy.yml` - manual/automated deployments
- **Validation**: `terraform-validate.yml` - code quality, security scanning
- **Drift Detection**: `terraform-drift-detection.yml` - scheduled state monitoring
- **Backend Setup**: `terraform-backend-setup.yml` - Azure Storage backend management

### Environment Promotion
Always promote through: `dev` → `qa` → `uat` → `prod`
- Test in dev first, then promote configs to higher environments
- Production requires manual approval in GitHub Actions
- Never skip environment validation

## Code Organization Rules

### Module Standards
- Each module in `/modules/{category}/{resource-type}/`
- Required files: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`
- **All variables must have descriptions and types**
- Use consistent naming: `{resource_type}-{purpose}-{environment}`

### Layer Integration
- Use `data` sources to reference outputs from other layers
- Store cross-layer outputs in `outputs.tf` of each layer
- **Environment-specific logic goes in `locals.tf`**
- Never hardcode values - use variables and locals

### Naming Conventions
- Resources: `{resource_type}-{purpose}-{environment}` (e.g., `vnet-hub-dev`)
- Variables: `snake_case` with descriptive names
- Tags: Include `Environment`, `ManagedBy`, `Purpose` as minimum

## Security & Best Practices

### State Security
- Backend uses Azure Storage with versioning enabled
- Resource locks on production resource groups
- Separate service principals for each environment (recommended)

### Validation Pipeline
- **Terraform fmt, validate** on every PR
- **TFLint, Checkov security scanning** in validation workflow
- **Cost estimation** with Infracost (if configured)
- **Documentation checks** for all modules

### Production Safeguards
- Manual approval required for production deployments
- 30-second delay before production apply
- Comprehensive logging and drift detection
- Automatic issue creation on production drift

## Quick Start Commands

```bash
# Initialize new environment backend
gh workflow run "Backend Setup" --field action=setup

# Deploy full environment
gh workflow run "Terraform Deploy" --field environment=dev --field layer=all --field action=apply

# Check for configuration drift
gh workflow run "Drift Detection" --field environment=prod

# Local development
make plan LAYER=networking ENV=dev
make apply LAYER=compute ENV=qa
```

## Key Files to Understand
- `Makefile` - Primary local development interface (25+ commands)
- `docs/deployment-guide.md` - Comprehensive deployment procedures
- `docs/architecture.md` - Detailed architecture decisions and layer interactions
- `docs/troubleshooting.md` - Common issues and solutions
- `.github/workflows/` - Complete CI/CD automation
# Resource Group Module

## Overview
This module creates an Azure Resource Group with standardized naming and tagging conventions.

## Features
- Standardized naming validation
- Consistent tagging strategy
- Optional management locks
- Location flexibility

## Usage

```hcl
module "resource_group" {
  source = "../../modules/resource-group"

  name     = "rg-myapp-prod-eastus"
  location = "eastus"
  
  tags = {
    Environment      = "prod"
    ManagedBy       = "terraform"
    Project         = "myapp"
    CostCenter      = "engineering"
    Owner           = "platform-team"
    Criticality     = "high"
    DataClassification = "confidential"
  }

  lock_level = "CanNotDelete"
  lock_notes = "Production resource group - contact platform team before deletion"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Resource group name (must start with rg-) | string | n/a | yes |
| location | Azure region | string | n/a | yes |
| tags | Standard tags | map(string) | {} | no |
| additional_tags | Additional tags | map(string) | {} | no |
| lock_level | Management lock level | string | null | no |
| lock_notes | Lock description | string | "..." | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Resource group ID |
| name | Resource group name |
| location | Resource group location |
| tags | Applied tags |

## Examples

### Basic Usage
```hcl
module "rg" {
  source   = "../../modules/resource-group"
  name     = "rg-app-dev-eastus"
  location = "eastus"
}
```

### With Lock
```hcl
module "rg_prod" {
  source     = "../../modules/resource-group"
  name       = "rg-app-prod-eastus"
  location   = "eastus"
  lock_level = "CanNotDelete"
}
```

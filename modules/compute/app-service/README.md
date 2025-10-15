# App Service Module

## Overview
This module creates an Azure App Service (Web App) with comprehensive configuration options including VNet integration, private endpoints, managed identity, and diagnostic settings.

## Features
- App Service Plan (Linux or Windows)
- Web App with configurable runtime stack
- VNet integration for secure networking
- Private endpoint support
- Managed identity (System or User-assigned)
- Application Insights integration
- IP restrictions and access control
- Diagnostic settings and logging
- Health checks
- Zone balancing for high availability

## Usage

### Basic Linux Web App
```hcl
module "web_app" {
  source = "../../modules/compute/app-service"

  app_service_plan_name = "plan-myapp-prod"
  app_service_name      = "app-myapp-prod"
  location              = "eastus"
  resource_group_name   = "rg-myapp-prod"
  
  os_type  = "Linux"
  sku_name = "P1v3"

  linux_fx_version = {
    node_version = "18-lts"
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18-lts"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = var.app_insights_key
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Web App with VNet Integration and Private Endpoint
```hcl
module "web_app_secure" {
  source = "../../modules/compute/app-service"

  app_service_plan_name = "plan-myapp-prod"
  app_service_name      = "app-myapp-prod-secure"
  location              = "eastus"
  resource_group_name   = "rg-myapp-prod"
  
  os_type  = "Linux"
  sku_name = "P1v3"

  # VNet Integration
  vnet_integration_subnet_id = azurerm_subnet.app_service.id
  vnet_route_all_enabled     = true

  # Private Endpoint
  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.private_endpoints.id
  private_dns_zone_ids       = [azurerm_private_dns_zone.app_service.id]
  public_network_access_enabled = false

  # Managed Identity
  identity_type = "SystemAssigned"

  # Application Stack
  linux_fx_version = {
    dotnet_version = "7.0"
  }

  # Security
  https_only          = true
  minimum_tls_version = "1.2"

  # Health Check
  health_check_path = "/health"

  # Logging
  log_analytics_workspace_id = var.log_analytics_id
  enable_application_logs    = true
  enable_http_logs          = true

  tags = var.common_tags
}
```

### Windows Web App with .NET
```hcl
module "web_app_windows" {
  source = "../../modules/compute/app-service"

  app_service_plan_name = "plan-myapp-prod-win"
  app_service_name      = "app-myapp-prod-win"
  location              = "eastus"
  resource_group_name   = "rg-myapp-prod"
  
  os_type  = "Windows"
  sku_name = "P1v3"

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = "Production"
  }

  tags = var.common_tags
}
```

### Web App with IP Restrictions
```hcl
module "web_app_restricted" {
  source = "../../modules/compute/app-service"

  app_service_plan_name = "plan-myapp-prod"
  app_service_name      = "app-myapp-restricted"
  location              = "eastus"
  resource_group_name   = "rg-myapp-prod"
  
  os_type  = "Linux"
  sku_name = "S1"

  ip_restrictions = [
    {
      name       = "AllowCorporateNetwork"
      priority   = 100
      action     = "Allow"
      ip_address = "203.0.113.0/24"
    },
    {
      name       = "AllowVNet"
      priority   = 200
      action     = "Allow"
      virtual_network_subnet_id = var.allowed_subnet_id
    }
  ]

  tags = var.common_tags
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
| app_service_plan_name | App Service Plan name | string | n/a | yes |
| app_service_name | App Service name | string | n/a | yes |
| location | Azure region | string | n/a | yes |
| resource_group_name | Resource group name | string | n/a | yes |
| os_type | OS type (Linux or Windows) | string | "Linux" | no |
| sku_name | SKU name (B1, S1, P1v3, etc.) | string | n/a | yes |
| linux_fx_version | Linux application stack | object | null | no |
| app_settings | Application settings | map(string) | {} | no |
| vnet_integration_subnet_id | VNet integration subnet ID | string | null | no |
| enable_private_endpoint | Enable private endpoint | bool | false | no |
| identity_type | Managed identity type | string | "SystemAssigned" | no |
| log_analytics_workspace_id | Log Analytics workspace ID | string | null | no |

See [variables.tf](./variables.tf) for complete list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| app_service_plan_id | App Service Plan ID |
| app_service_id | App Service ID |
| app_service_default_hostname | Default hostname |
| app_service_identity_principal_id | Managed identity principal ID |
| private_endpoint_id | Private endpoint ID (if enabled) |

See [outputs.tf](./outputs.tf) for complete list of outputs.

## Supported Runtimes

### Linux
- Node.js (18-lts, 20-lts)
- Python (3.9, 3.10, 3.11)
- .NET (6.0, 7.0, 8.0)
- Java (11, 17, 21)
- PHP (8.0, 8.1, 8.2)
- Docker containers

### Windows
- .NET Framework
- .NET Core
- Node.js
- PHP
- Java

## SKU Options

| Tier | SKU | vCPU | RAM | Description |
|------|-----|------|-----|-------------|
| Free | F1 | Shared | 1 GB | Development/testing |
| Shared | D1 | Shared | 1 GB | Development/testing |
| Basic | B1, B2, B3 | 1-4 | 1.75-7 GB | Basic apps |
| Standard | S1, S2, S3 | 1-4 | 1.75-7 GB | Production apps |
| Premium v3 | P0v3, P1v3, P2v3, P3v3 | 1-8 | 4-32 GB | High performance |

## Notes

- Always use `https_only = true` for production
- Set `minimum_tls_version = "1.2"` or higher
- Use `always_on = true` for production to prevent cold starts
- Enable VNet integration for secure networking
- Use private endpoints for maximum security
- Configure health checks for auto-healing
- Enable diagnostic logs for troubleshooting
- Use managed identity instead of connection strings
- Set appropriate IP restrictions for security

## Examples

See the compute layer implementation in `/layers/compute/` for real-world usage examples.

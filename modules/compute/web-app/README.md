# Web App Module

This module creates an Azure Web App (App Service) with comprehensive configuration options for both Linux and Windows workloads.

## Features

- ✅ **Flexible OS Support**: Linux and Windows web apps
- ✅ **App Service Plan**: Configurable SKU with zone redundancy
- ✅ **VNet Integration**: Connect to virtual networks
- ✅ **Private Endpoints**: Secure access via private connectivity
- ✅ **Managed Identity**: SystemAssigned or UserAssigned identities
- ✅ **Health Checks**: Configurable health monitoring
- ✅ **Logging**: Application and HTTP logs with retention
- ✅ **Security**: HTTPS-only, TLS 1.2+, IP restrictions
- ✅ **Diagnostic Settings**: Integration with Log Analytics

## Usage

### Basic Linux Web App

```hcl
module "web_app" {
  source = "../../modules/compute/web-app"

  name                = "app-myapp-prod"
  location            = "eastus"
  resource_group_name = "rg-compute"

  service_plan_name = "plan-myapp-prod"
  os_type           = "Linux"
  sku_name          = "P1v3"

  application_stack = {
    node_version = "20-lts"
  }

  app_settings = {
    "NODE_ENV" = "production"
  }

  tags = {
    Environment = "production"
  }
}
```

### Windows Web App with .NET

```hcl
module "web_app" {
  source = "../../modules/compute/web-app"

  name                = "app-myapp-prod"
  location            = "eastus"
  resource_group_name = "rg-compute"

  service_plan_name = "plan-myapp-prod"
  os_type           = "Windows"
  sku_name          = "P1v3"

  application_stack = {
    current_stack  = "dotnet"
    dotnet_version = "v8.0"
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = "Production"
  }

  tags = {
    Environment = "production"
  }
}
```

### Web App with VNet Integration and Private Endpoint

```hcl
module "web_app" {
  source = "../../modules/compute/web-app"

  name                = "app-myapp-prod"
  location            = "eastus"
  resource_group_name = "rg-compute"

  service_plan_name = "plan-myapp-prod"
  os_type           = "Linux"
  sku_name          = "P1v3"
  zone_redundant    = true

  # VNet Integration for outbound traffic
  vnet_integration_subnet_id = azurerm_subnet.app_service.id
  vnet_route_all_enabled     = true

  # Private Endpoint for inbound traffic
  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.private_endpoints.id
  private_dns_zone_ids       = [azurerm_private_dns_zone.web_app.id]

  public_network_access_enabled = false

  application_stack = {
    node_version = "20-lts"
  }

  health_check_path = "/health"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = "production"
  }
}
```

### Web App with Docker Container

```hcl
module "web_app" {
  source = "../../modules/compute/web-app"

  name                = "app-myapp-prod"
  location            = "eastus"
  resource_group_name = "rg-compute"

  service_plan_name = "plan-myapp-prod"
  os_type           = "Linux"
  sku_name          = "P1v3"

  application_stack = {
    docker_image     = "myregistry.azurecr.io/myapp"
    docker_image_tag = "latest"
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://myregistry.azurecr.io"
    "DOCKER_REGISTRY_SERVER_USERNAME" = "myregistry"
    "DOCKER_REGISTRY_SERVER_PASSWORD" = var.acr_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.acr.id]

  tags = {
    Environment = "production"
  }
}
```

### Web App with IP Restrictions

```hcl
module "web_app" {
  source = "../../modules/compute/web-app"

  name                = "app-myapp-prod"
  location            = "eastus"
  resource_group_name = "rg-compute"

  service_plan_name = "plan-myapp-prod"
  os_type           = "Linux"
  sku_name          = "P1v3"

  application_stack = {
    node_version = "20-lts"
  }

  # Only allow traffic from specific IPs and subnets
  ip_restrictions = [
    {
      name       = "AllowOfficeIP"
      ip_address = "203.0.113.0/24"
      action     = "Allow"
      priority   = 100
    },
    {
      name                      = "AllowAppGateway"
      virtual_network_subnet_id = azurerm_subnet.appgw.id
      action                    = "Allow"
      priority                  = 200
    },
    {
      name        = "AllowFrontDoor"
      service_tag = "AzureFrontDoor.Backend"
      action      = "Allow"
      priority    = 300
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Application Stacks

### Linux

- **Node.js**: `node_version = "18-lts"` or `"20-lts"`
- **Python**: `python_version = "3.11"` or `"3.12"`
- **PHP**: `php_version = "8.2"`
- **.NET**: `dotnet_version = "6.0"` or `"8.0"`
- **Java**: `java_version = "17"`
- **Ruby**: `ruby_version = "3.2"`
- **Docker**: `docker_image` and `docker_image_tag`

### Windows

- **Current Stack**: `current_stack = "dotnet"`, `"node"`, `"python"`, `"php"`, `"java"`
- **.NET**: `dotnet_version = "v6.0"` or `"v8.0"`
- **Node.js**: `node_version = "~18"` or `"~20"`
- **Python**: `python_version = "3.11"`
- **PHP**: `php_version = "8.2"`
- **Java**: `java_version = "17"`

## SKU Recommendations

### Development
- **B1** (Basic): $13/month - 1 core, 1.75GB RAM
- **B2** (Basic): $25/month - 2 cores, 3.5GB RAM

### QA/UAT
- **S1** (Standard): $70/month - 1 core, 1.75GB RAM
- **S2** (Standard): $140/month - 2 cores, 3.5GB RAM

### Production
- **P1v3** (Premium): $117/month - 2 cores, 8GB RAM
- **P2v3** (Premium): $234/month - 4 cores, 16GB RAM
- **P3v3** (Premium): $468/month - 8 cores, 32GB RAM

## Security Best Practices

1. **Always use HTTPS**: `https_only = true`
2. **Minimum TLS 1.2**: `minimum_tls_version = "1.2"`
3. **Disable FTP**: `ftps_state = "Disabled"`
4. **Use Managed Identity**: Avoid storing credentials
5. **Enable Private Endpoints**: For production workloads
6. **Restrict Public Access**: Use IP restrictions or disable public access
7. **VNet Integration**: Route all traffic through VNet
8. **Health Checks**: Monitor application health
9. **Enable Logging**: Application and HTTP logs
10. **Use Zone Redundancy**: For high availability

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the web app | string | - | yes |
| location | Azure region | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| service_plan_name | App Service Plan name | string | - | yes |
| os_type | OS type (Linux or Windows) | string | "Linux" | no |
| sku_name | SKU name | string | "P1v3" | no |
| zone_redundant | Enable zone redundancy | bool | false | no |
| application_stack | Application stack configuration | any | null | no |
| app_settings | Application settings | map(string) | {} | no |
| connection_strings | Connection strings | list(object) | [] | no |
| vnet_integration_subnet_id | Subnet for VNet integration | string | null | no |
| enable_private_endpoint | Enable private endpoint | bool | false | no |
| health_check_path | Health check endpoint | string | null | no |
| log_analytics_workspace_id | Log Analytics workspace ID | string | null | no |

See [variables.tf](./variables.tf) for complete list.

## Outputs

| Name | Description |
|------|-------------|
| id | Web App ID |
| name | Web App name |
| default_hostname | Default hostname |
| outbound_ip_addresses | Outbound IP addresses |
| identity_principal_id | Managed identity principal ID |
| service_plan_id | App Service Plan ID |

See [outputs.tf](./outputs.tf) for complete list.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | ~> 3.0 |

## Notes

- The module automatically creates the App Service Plan
- For Windows apps, use `current_stack` to specify the technology
- For Linux apps, specify the runtime version directly
- Connection strings are marked as sensitive
- Zone redundancy requires Premium SKU
- Private endpoints require Standard or Premium SKU
- VNet integration requires Standard or Premium SKU

## Examples

See the [examples directory](../../../layers/compute/environments/) for complete environment configurations:
- [Development](../../../layers/compute/environments/dev/terraform.tfvars)
- [QA](../../../layers/compute/environments/qa/terraform.tfvars)
- [UAT](../../../layers/compute/environments/uat/terraform.tfvars)
- [Production](../../../layers/compute/environments/prod/terraform.tfvars)

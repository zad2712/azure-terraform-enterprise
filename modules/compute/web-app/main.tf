/**
 * Web App Module
 * 
 * Creates an Azure Web App (App Service) with configuration options
 */

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

  zone_balancing_enabled = var.zone_redundant

  tags = var.tags
}

resource "azurerm_linux_web_app" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  https_only                    = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.vnet_integration_subnet_id

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  site_config {
    always_on                               = var.always_on
    http2_enabled                           = var.http2_enabled
    minimum_tls_version                     = var.minimum_tls_version
    ftps_state                              = var.ftps_state
    vnet_route_all_enabled                  = var.vnet_route_all_enabled
    health_check_path                       = var.health_check_path
    health_check_eviction_time_in_min       = var.health_check_eviction_time

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        docker_image        = lookup(application_stack.value, "docker_image", null)
        docker_image_tag    = lookup(application_stack.value, "docker_image_tag", null)
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
        java_version        = lookup(application_stack.value, "java_version", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        php_version         = lookup(application_stack.value, "php_version", null)
        python_version      = lookup(application_stack.value, "python_version", null)
        ruby_version        = lookup(application_stack.value, "ruby_version", null)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        name                      = ip_restriction.value.name
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        service_tag               = lookup(ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
        action                    = lookup(ip_restriction.value, "action", "Allow")
        priority                  = lookup(ip_restriction.value, "priority", 65000)
      }
    }

    dynamic "cors" {
      for_each = var.cors_allowed_origins != null ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  logs {
    detailed_error_messages = var.detailed_error_messages
    failed_request_tracing  = var.failed_request_tracing

    dynamic "application_logs" {
      for_each = var.enable_application_logs ? [1] : []
      content {
        file_system_level = var.application_logs_level
      }
    }

    dynamic "http_logs" {
      for_each = var.enable_http_logs ? [1] : []
      content {
        file_system {
          retention_in_days = var.http_logs_retention_days
          retention_in_mb   = var.http_logs_retention_mb
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_windows_web_app" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  https_only                    = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.vnet_integration_subnet_id

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  site_config {
    always_on                               = var.always_on
    http2_enabled                           = var.http2_enabled
    minimum_tls_version                     = var.minimum_tls_version
    ftps_state                              = var.ftps_state
    vnet_route_all_enabled                  = var.vnet_route_all_enabled
    health_check_path                       = var.health_check_path
    health_check_eviction_time_in_min       = var.health_check_eviction_time

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        current_stack       = lookup(application_stack.value, "current_stack", null)
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
        java_version        = lookup(application_stack.value, "java_version", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        php_version         = lookup(application_stack.value, "php_version", null)
        python              = lookup(application_stack.value, "python_version", null)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        name                      = ip_restriction.value.name
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        service_tag               = lookup(ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
        action                    = lookup(ip_restriction.value, "action", "Allow")
        priority                  = lookup(ip_restriction.value, "priority", 65000)
      }
    }

    dynamic "cors" {
      for_each = var.cors_allowed_origins != null ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  logs {
    detailed_error_messages = var.detailed_error_messages
    failed_request_tracing  = var.failed_request_tracing

    dynamic "application_logs" {
      for_each = var.enable_application_logs ? [1] : []
      content {
        file_system_level = var.application_logs_level
      }
    }

    dynamic "http_logs" {
      for_each = var.enable_http_logs ? [1] : []
      content {
        file_system {
          retention_in_days = var.http_logs_retention_days
          retention_in_mb   = var.http_logs_retention_mb
        }
      }
    }
  }

  tags = var.tags
}

# Private Endpoint for Web App
resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServicePlatformLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

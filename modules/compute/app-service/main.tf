/**
 * App Service Module
 * 
 * Creates an Azure App Service (Web App) with:
 * - App Service Plan with auto-scaling
 * - App Service with deployment slots
 * - VNet integration
 * - Managed Identity
 * - Application Insights integration
 * - Custom domains and SSL
 * - Diagnostic settings
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

#=============================================================================
# App Service Plan
#=============================================================================

resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

  worker_count                 = var.worker_count
  per_site_scaling_enabled     = var.per_site_scaling_enabled
  zone_balancing_enabled       = var.zone_balancing_enabled
  maximum_elastic_worker_count = var.maximum_elastic_worker_count

  tags = var.tags
}

#=============================================================================
# App Service
#=============================================================================

resource "azurerm_linux_web_app" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  https_only                    = var.https_only
  client_affinity_enabled       = var.client_affinity_enabled
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.vnet_integration_subnet_id

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    vnet_route_all_enabled            = var.vnet_route_all_enabled
    websockets_enabled                = var.websockets_enabled
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = var.docker_registry_url
      dotnet_version      = var.dotnet_version
      java_version        = var.java_version
      node_version        = var.node_version
      php_version         = var.php_version
      python_version      = var.python_version
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
        service_tag               = lookup(ip_restriction.value, "service_tag", null)
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

  app_settings = merge(
    var.app_settings,
    var.application_insights_key != null ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.application_insights_key
    } : {}
  )

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

    application_logs {
      file_system_level = var.app_log_level
    }

    http_logs {
      file_system {
        retention_in_days = var.http_logs_retention_days
        retention_in_mb   = var.http_logs_retention_mb
      }
    }
  }

  tags = var.tags
}

resource "azurerm_windows_web_app" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  https_only                    = var.https_only
  client_affinity_enabled       = var.client_affinity_enabled
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.vnet_integration_subnet_id

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    vnet_route_all_enabled            = var.vnet_route_all_enabled
    websockets_enabled                = var.websockets_enabled
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

    application_stack {
      current_stack  = var.windows_current_stack
      dotnet_version = var.dotnet_version
      node_version   = var.node_version
      php_version    = var.php_version
      python         = var.python_version != null ? true : false
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
        service_tag               = lookup(ip_restriction.value, "service_tag", null)
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

  app_settings = merge(
    var.app_settings,
    var.application_insights_key != null ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.application_insights_key
    } : {}
  )

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

    application_logs {
      file_system_level = var.app_log_level
    }

    http_logs {
      file_system {
        retention_in_days = var.http_logs_retention_days
        retention_in_mb   = var.http_logs_retention_mb
      }
    }
  }

  tags = var.tags
}

#=============================================================================
# Deployment Slots
#=============================================================================

resource "azurerm_linux_web_app_slot" "staging" {
  count = var.os_type == "Linux" && var.enable_staging_slot ? 1 : 0

  name           = "staging"
  app_service_id = azurerm_linux_web_app.this[0].id

  site_config {
    always_on           = var.always_on
    ftps_state          = var.ftps_state
    http2_enabled       = var.http2_enabled
    minimum_tls_version = var.minimum_tls_version
  }

  tags = var.tags
}

resource "azurerm_windows_web_app_slot" "staging" {
  count = var.os_type == "Windows" && var.enable_staging_slot ? 1 : 0

  name           = "staging"
  app_service_id = azurerm_windows_web_app.this[0].id

  site_config {
    always_on           = var.always_on
    ftps_state          = var.ftps_state
    http2_enabled       = var.http2_enabled
    minimum_tls_version = var.minimum_tls_version
  }

  tags = var.tags
}

#=============================================================================
# Diagnostic Settings
#=============================================================================

resource "azurerm_monitor_diagnostic_setting" "app_service" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.app_service_name}-diagnostics"
  target_resource_id         = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = [
      "AppServiceHTTPLogs",
      "AppServiceConsoleLogs",
      "AppServiceAppLogs",
      "AppServiceAuditLogs",
      "AppServiceIPSecAuditLogs",
      "AppServicePlatformLogs"
    ]
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "service_plan" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.service_plan_name}-diagnostics"
  target_resource_id         = azurerm_service_plan.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

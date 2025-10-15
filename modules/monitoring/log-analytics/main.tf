/**
 * Log Analytics Workspace Module
 * 
 * Creates a Log Analytics workspace for centralized logging and monitoring
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

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb

  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled

  tags = var.tags
}

# Diagnostic Settings for the workspace itself
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_log_analytics_workspace.this.id
  storage_account_id         = var.diagnostics_storage_account_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Solutions (optional)
resource "azurerm_log_analytics_solution" "this" {
  for_each = toset(var.solutions)

  solution_name         = each.value
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/${each.value}"
  }

  tags = var.tags
}

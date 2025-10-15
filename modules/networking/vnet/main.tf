/**
 * Virtual Network Module
 * 
 * Creates an Azure Virtual Network with subnets, NSGs, and diagnostic settings
 * 
 * Features:
 * - Multiple subnets with service delegation
 * - DDoS protection plan integration
 * - DNS servers configuration
 * - Diagnostic settings for monitoring
 * - Network watcher integration
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

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != null ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_virtual_network.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

# Network Watcher Flow Logs (for NSGs attached to subnets)
resource "azurerm_network_watcher_flow_log" "this" {
  count                     = var.enable_flow_logs && var.network_watcher_name != null ? 1 : 0
  name                      = "${var.name}-flowlog"
  network_watcher_name      = var.network_watcher_name
  resource_group_name       = var.network_watcher_resource_group_name
  network_security_group_id = var.nsg_id_for_flow_logs
  storage_account_id        = var.flow_logs_storage_account_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = var.flow_logs_retention_days
  }

  traffic_analytics {
    enabled               = var.enable_traffic_analytics
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.location
    workspace_resource_id = var.log_analytics_workspace_id
    interval_in_minutes   = 10
  }
}

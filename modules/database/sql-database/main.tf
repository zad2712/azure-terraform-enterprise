/**
 * Azure SQL Database Module
 * 
 * Creates Azure SQL Server and Database with:
 * - Elastic pool support
 * - Private endpoint
 * - Backup configuration
 * - Threat protection
 * - Transparent data encryption
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

resource "azurerm_mssql_server" "this" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = "1.2"
  public_network_access_enabled = !var.private_endpoint_enabled

  azuread_administrator {
    login_username = var.azuread_admin_login
    object_id      = var.azuread_admin_object_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "this" {
  name                        = var.database_name
  server_id                   = azurerm_mssql_server.this.id
  collation                   = var.collation
  sku_name                    = var.sku_name
  max_size_gb                 = var.max_size_gb
  zone_redundant              = var.zone_redundant
  read_scale                  = var.read_scale
  auto_pause_delay_in_minutes = var.auto_pause_delay_in_minutes
  min_capacity                = var.min_capacity
  storage_account_type        = var.backup_storage_redundancy

  short_term_retention_policy {
    retention_days           = var.short_term_retention_days
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    weekly_retention  = var.ltr_weekly_retention
    monthly_retention = var.ltr_monthly_retention
    yearly_retention  = var.ltr_yearly_retention
    week_of_year      = var.ltr_week_of_year
  }

  threat_detection_policy {
    state                      = "Enabled"
    email_account_admins       = "Enabled"
    email_addresses            = var.threat_detection_emails
    retention_days             = var.threat_detection_retention_days
    storage_endpoint           = var.threat_detection_storage_endpoint
    storage_account_access_key = var.threat_detection_storage_key
  }

  tags = var.tags
}

# Transparent Data Encryption
resource "azurerm_mssql_server_transparent_data_encryption" "this" {
  count              = var.enable_tde ? 1 : 0
  server_id          = azurerm_mssql_server.this.id
  key_vault_key_id   = var.tde_key_vault_key_id
  auto_rotation_enabled = true
}

# Firewall Rules
resource "azurerm_mssql_firewall_rule" "this" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# Virtual Network Rule
resource "azurerm_mssql_virtual_network_rule" "this" {
  for_each = var.vnet_rules

  name      = each.key
  server_id = azurerm_mssql_server.this.id
  subnet_id = each.value
}

# Private Endpoint
resource "azurerm_private_endpoint" "this" {
  count               = var.private_endpoint_enabled ? 1 : 0
  name                = "${var.server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.server_name}-psc"
    private_connection_resource_id = azurerm_mssql_server.this.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "${var.database_name}-diagnostics"
  target_resource_id         = azurerm_mssql_database.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = [
      "SQLInsights",
      "AutomaticTuning",
      "QueryStoreRuntimeStatistics",
      "QueryStoreWaitStatistics",
      "Errors",
      "DatabaseWaitStatistics",
      "Timeouts",
      "Blocks",
      "Deadlocks"
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

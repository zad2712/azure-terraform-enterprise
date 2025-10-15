/**
 * Azure PostgreSQL Flexible Server Module
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

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgresql_version
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  zone                   = var.zone
  
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  
  high_availability {
    mode                      = var.high_availability_mode
    standby_availability_zone = var.standby_availability_zone
  }

  maintenance_window {
    day_of_week  = var.maintenance_window.day_of_week
    start_hour   = var.maintenance_window.start_hour
    start_minute = var.maintenance_window.start_minute
  }

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each = toset(var.databases)
  
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = var.collation
  charset   = var.charset
}

resource "azurerm_postgresql_flexible_server_configuration" "this" {
  for_each = var.postgresql_configurations
  
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = each.value
}

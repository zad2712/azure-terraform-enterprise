# Resource Group Outputs
output "resource_group_id" {
  description = "Database resource group ID"
  value       = module.database_rg.id
}

output "resource_group_name" {
  description = "Database resource group name"
  value       = module.database_rg.name
}

# SQL Database Outputs
output "sql_server_id" {
  description = "SQL Server ID"
  value       = var.enable_sql_database ? module.sql_database[0].server_id : null
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = var.enable_sql_database ? module.sql_database[0].server_fqdn : null
}

output "sql_database_id" {
  description = "SQL Database ID"
  value       = var.enable_sql_database ? module.sql_database[0].database_id : null
}

# Redis Cache Outputs
output "redis_id" {
  description = "Redis Cache ID"
  value       = var.enable_redis_cache ? azurerm_redis_cache.this[0].id : null
}

output "redis_hostname" {
  description = "Redis hostname"
  value       = var.enable_redis_cache ? azurerm_redis_cache.this[0].hostname : null
}

output "redis_port" {
  description = "Redis SSL port"
  value       = var.enable_redis_cache ? azurerm_redis_cache.this[0].ssl_port : null
}

# Cross-layer reference
output "database_config" {
  description = "Database configuration for cross-layer reference"
  value = {
    resource_group = module.database_rg.name
    sql_server     = var.enable_sql_database ? module.sql_database[0].server_name : null
    redis_hostname = var.enable_redis_cache ? azurerm_redis_cache.this[0].hostname : null
  }
}

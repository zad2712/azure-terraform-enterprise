output "server_id" {
  description = "SQL Server ID"
  value       = azurerm_mssql_server.this.id
}

output "server_name" {
  description = "SQL Server name"
  value       = azurerm_mssql_server.this.name
}

output "server_fqdn" {
  description = "SQL Server FQDN"
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_id" {
  description = "Database ID"
  value       = azurerm_mssql_database.this.id
}

output "database_name" {
  description = "Database name"
  value       = azurerm_mssql_database.this.name
}

output "connection_string" {
  description = "Database connection string (sensitive)"
  value       = "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.this.name};User ID=${var.administrator_login};"
  sensitive   = true
}

output "private_endpoint_id" {
  description = "Private endpoint ID"
  value       = var.private_endpoint_enabled ? azurerm_private_endpoint.this[0].id : null
}

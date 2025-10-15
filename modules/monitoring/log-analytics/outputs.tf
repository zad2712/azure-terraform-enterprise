output "id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Workspace ID (GUID)"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "Primary shared key"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "Secondary shared key"
  value       = azurerm_log_analytics_workspace.this.secondary_shared_key
  sensitive   = true
}

output "location" {
  description = "Log Analytics workspace location"
  value       = azurerm_log_analytics_workspace.this.location
}

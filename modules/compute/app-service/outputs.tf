# Service Plan Outputs
output "service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.this.id
}

output "service_plan_name" {
  description = "App Service Plan name"
  value       = azurerm_service_plan.this.name
}

# App Service Outputs
output "app_service_id" {
  description = "App Service ID"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
}

output "app_service_name" {
  description = "App Service name"
  value       = var.app_service_name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].default_hostname : azurerm_windows_web_app.this[0].default_hostname
}

output "app_service_outbound_ip_addresses" {
  description = "Outbound IP addresses of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].outbound_ip_addresses : azurerm_windows_web_app.this[0].outbound_ip_addresses
}

output "app_service_possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].possible_outbound_ip_addresses : azurerm_windows_web_app.this[0].possible_outbound_ip_addresses
}

# Identity Outputs
output "identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].identity[0].principal_id : azurerm_windows_web_app.this[0].identity[0].principal_id
}

output "identity_tenant_id" {
  description = "Tenant ID of the managed identity"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].identity[0].tenant_id : azurerm_windows_web_app.this[0].identity[0].tenant_id
}

# Staging Slot Outputs
output "staging_slot_id" {
  description = "Staging slot ID"
  value       = var.enable_staging_slot ? (var.os_type == "Linux" ? azurerm_linux_web_app_slot.staging[0].id : azurerm_windows_web_app_slot.staging[0].id) : null
}

output "staging_slot_hostname" {
  description = "Staging slot hostname"
  value       = var.enable_staging_slot ? (var.os_type == "Linux" ? azurerm_linux_web_app_slot.staging[0].default_hostname : azurerm_windows_web_app_slot.staging[0].default_hostname) : null
}

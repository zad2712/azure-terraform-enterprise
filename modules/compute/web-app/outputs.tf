# Service Plan Outputs
output "service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.this.id
}

output "service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.this.name
}

# Web App Outputs
output "id" {
  description = "ID of the web app"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
}

output "name" {
  description = "Name of the web app"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].name : azurerm_windows_web_app.this[0].name
}

output "default_hostname" {
  description = "Default hostname of the web app"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].default_hostname : azurerm_windows_web_app.this[0].default_hostname
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses of the web app"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].outbound_ip_addresses : azurerm_windows_web_app.this[0].outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses of the web app"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].possible_outbound_ip_addresses : azurerm_windows_web_app.this[0].possible_outbound_ip_addresses
}

output "identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].identity[0].principal_id : azurerm_windows_web_app.this[0].identity[0].principal_id
}

output "identity_tenant_id" {
  description = "Tenant ID of the managed identity"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].identity[0].tenant_id : azurerm_windows_web_app.this[0].identity[0].tenant_id
}

# Private Endpoint Outputs
output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
}

output "private_endpoint_ip_address" {
  description = "Private IP address of the private endpoint"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
}

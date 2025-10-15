output "id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.this.name
}

output "address_space" {
  description = "Virtual network address space"
  value       = azurerm_virtual_network.this.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_virtual_network.this.subnet : v.name => v.id }
}

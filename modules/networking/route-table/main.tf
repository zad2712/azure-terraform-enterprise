/**
 * Route Table Module
 * 
 * Creates a route table with custom routes
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

resource "azurerm_route_table" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  tags = var.tags
}

resource "azurerm_route" "this" {
  for_each = { for route in var.routes : route.name => route }

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = lookup(each.value, "next_hop_in_ip_address", null)
}

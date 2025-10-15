/**
 * Route Table Association Module
 * 
 * Associates a route table with a subnet
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

resource "azurerm_subnet_route_table_association" "this" {
  subnet_id      = var.subnet_id
  route_table_id = var.route_table_id
}

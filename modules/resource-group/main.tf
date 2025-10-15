/**
 * Resource Group Module
 * 
 * Creates an Azure Resource Group with standard tags
 * 
 * Features:
 * - Standardized naming convention
 * - Consistent tagging strategy
 * - Location flexibility
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

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = merge(var.tags, var.additional_tags)

  lifecycle {
    prevent_destroy = false
  }
}

# Management Lock (Optional)
resource "azurerm_management_lock" "this" {
  count      = var.lock_level != null ? 1 : 0
  name       = "${var.name}-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}

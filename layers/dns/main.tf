/**
 * DNS Layer - Root Module
 * This root module orchestrates DNS infrastructure by calling modules.
 */

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm"; version = "~> 3.0" }
  }
  backend "azurerm" {}
}

provider "azurerm" { features {} }

data "azurerm_client_config" "current" {}

module "dns_rg" {
  source   = "../../modules/resource-group"
  name     = "rg-${local.naming_prefix}-dns-${var.location}"
  location = var.location
  tags     = local.common_tags
  lock_level = var.environment == "prod" ? "CanNotDelete" : null
}

# Example: DNS Zone Module
# module "dns_zone" {
#   source = "../../modules/dns/dns-zone"
#   name   = "example.com"
#   resource_group_name = module.dns_rg.name
#   tags   = local.common_tags
# }

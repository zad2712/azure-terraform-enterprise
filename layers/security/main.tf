/**
 * Security Layer - Root Configuration
 * 
 * This layer manages security infrastructure including:
 * - Azure Key Vault
 * - Managed Identities
 * - Private DNS Zones
 * - Azure Policy
 * - Security Center configurations
 */

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # Backend configuration provided via backend.conf file
    # terraform init -backend-config=environments/<env>/backend.conf
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Remote state - networking layer
data "terraform_remote_state" "networking" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstate"
    key                  = "networking-${var.environment}.tfstate"
    resource_group_name  = var.state_resource_group_name
  }
}

#=============================================================================
# Resource Group
#=============================================================================

module "security_rg" {
  source = "../../modules/resource-group"

  name     = "rg-${local.naming_prefix}-security-${var.location}"
  location = var.location
  tags     = local.common_tags

  lock_level = var.environment == "prod" ? "CanNotDelete" : null
}

#=============================================================================
# Key Vault
#=============================================================================

module "key_vault" {
  source = "../../modules/security/key-vault"

  name                = "kv-${local.naming_prefix}-${local.location_short}"
  location            = var.location
  resource_group_name = module.security_rg.name
  
  sku_name                     = var.key_vault_sku
  soft_delete_retention_days   = local.security_config.kv_soft_delete_retention
  purge_protection_enabled     = local.security_config.kv_purge_protection
  enable_rbac_authorization    = true
  public_network_access_enabled = !local.security_config.kv_private_endpoint_only

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = local.security_config.kv_default_action
    ip_rules                   = var.allowed_ip_addresses
    virtual_network_subnet_ids = []
  }

  # Private endpoint configuration
  private_endpoint_subnet_id = local.security_config.enable_private_endpoints ? data.terraform_remote_state.networking.outputs.subnet_private_endpoints_id : null
  private_dns_zone_ids       = []  # Add private DNS zone IDs

  log_analytics_workspace_id = null  # Add when monitoring layer is deployed

  tags = local.common_tags

  depends_on = [module.security_rg]
}

#=============================================================================
# Managed Identities
#=============================================================================

# User-assigned managed identity for AKS workloads
resource "azurerm_user_assigned_identity" "aks_workload" {
  count = var.enable_aks_workload_identity ? 1 : 0

  name                = "id-${local.naming_prefix}-aks-workload"
  location            = var.location
  resource_group_name = module.security_rg.name

  tags = local.common_tags
}

# User-assigned managed identity for App Services
resource "azurerm_user_assigned_identity" "app_service" {
  count = var.enable_app_service_identity ? 1 : 0

  name                = "id-${local.naming_prefix}-appservice"
  location            = var.location
  resource_group_name = module.security_rg.name

  tags = local.common_tags
}

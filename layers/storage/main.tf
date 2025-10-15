/**
 * Storage Layer - Root Configuration
 * 
 * This layer manages storage infrastructure including:
 * - Storage Accounts
 * - Blob Containers
 * - File Shares
 * - Private Endpoints
 */

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# Data sources
data "azurerm_client_config" "current" {}

# Remote state - networking
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

module "storage_rg" {
  source = "../../modules/resource-group"

  name     = "rg-${local.naming_prefix}-storage-${var.location}"
  location = var.location
  tags     = local.common_tags

  lock_level = var.environment == "prod" ? "CanNotDelete" : null
}

#=============================================================================
# Storage Account - General Purpose
#=============================================================================

module "storage_account_general" {
  source = "../../modules/storage/storage-account"

  name                = "st${var.project_name}${var.environment}gen${random_string.storage_suffix.result}"
  resource_group_name = module.storage_rg.name
  location            = var.location
  
  account_tier             = local.storage_config.account_tier
  replication_type         = local.storage_config.replication_type
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  
  enable_versioning            = local.storage_config.enable_versioning
  enable_change_feed           = local.storage_config.enable_change_feed
  blob_soft_delete_retention_days       = local.storage_config.soft_delete_retention
  container_soft_delete_retention_days  = local.storage_config.soft_delete_retention
  
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  private_endpoint_only           = local.storage_config.private_endpoint_only
  
  network_rules_default_action = local.storage_config.network_default_action
  network_rules_bypass         = ["AzureServices"]
  allowed_subnet_ids           = [data.terraform_remote_state.networking.outputs.subnet_app_service_id]
  
  enable_private_endpoint    = local.storage_config.enable_private_endpoints
  private_endpoint_subnet_id = data.terraform_remote_state.networking.outputs.subnet_private_endpoints_id
  private_dns_zone_ids       = []
  
  lifecycle_rules = local.storage_config.lifecycle_rules
  
  log_analytics_workspace_id = null
  
  tags = local.common_tags
  
  depends_on = [module.storage_rg]
}

# Random suffix for storage account name
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

#=============================================================================
# Blob Containers
#=============================================================================

resource "azurerm_storage_container" "containers" {
  for_each = var.blob_containers

  name                  = each.key
  storage_account_name  = module.storage_account_general.name
  container_access_type = each.value.access_type
}

#=============================================================================
# File Shares
#=============================================================================

resource "azurerm_storage_share" "shares" {
  for_each = var.file_shares

  name                 = each.key
  storage_account_name = module.storage_account_general.name
  quota                = each.value.quota_gb
}

#=============================================================================
# Storage Account - Application Data (Optional)
#=============================================================================

module "storage_account_app" {
  count  = var.enable_app_storage_account ? 1 : 0
  source = "../../modules/storage/storage-account"

  name                = "st${var.project_name}${var.environment}app${random_string.storage_suffix.result}"
  resource_group_name = module.storage_rg.name
  location            = var.location
  
  account_tier     = local.storage_config.account_tier
  replication_type = local.storage_config.replication_type
  account_kind     = "StorageV2"
  access_tier      = "Hot"
  
  enable_versioning                 = true
  blob_soft_delete_retention_days   = local.storage_config.soft_delete_retention
  
  allow_nested_items_to_be_public = false
  private_endpoint_only           = local.storage_config.private_endpoint_only
  
  network_rules_default_action = "Deny"
  network_rules_bypass         = ["AzureServices"]
  allowed_subnet_ids           = [
    data.terraform_remote_state.networking.outputs.subnet_aks_user_id,
    data.terraform_remote_state.networking.outputs.subnet_app_service_id
  ]
  
  enable_private_endpoint    = local.storage_config.enable_private_endpoints
  private_endpoint_subnet_id = data.terraform_remote_state.networking.outputs.subnet_private_endpoints_id
  
  tags = local.common_tags
}

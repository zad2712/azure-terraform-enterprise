/**
 * Database Layer - Root Configuration
 * 
 * This layer manages database infrastructure including:
 * - Azure SQL Database
 * - Azure Database for PostgreSQL
 * - Azure Database for MySQL
 * - Azure Cosmos DB
 * - Azure Redis Cache
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

# Remote state - security
data "terraform_remote_state" "security" {
  backend = "azurerm"
  config = {
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstate"
    key                  = "security-${var.environment}.tfstate"
    resource_group_name  = var.state_resource_group_name
  }
}

#=============================================================================
# Resource Group
#=============================================================================

module "database_rg" {
  source = "../../modules/resource-group"

  name     = "rg-${local.naming_prefix}-database-${var.location}"
  location = var.location
  tags     = local.common_tags

  lock_level = var.environment == "prod" ? "CanNotDelete" : null
}

#=============================================================================
# Azure SQL Database
#=============================================================================

# Generate random password for SQL admin
resource "random_password" "sql_admin" {
  count   = var.enable_sql_database ? 1 : 0
  length  = 24
  special = true
}

module "sql_database" {
  count  = var.enable_sql_database ? 1 : 0
  source = "../../modules/database/sql-database"

  server_name                  = "sql-${local.naming_prefix}-${local.location_short}"
  database_name                = var.sql_database_name
  resource_group_name          = module.database_rg.name
  location                     = var.location
  server_version               = "12.0"
  
  administrator_login          = var.sql_admin_login
  administrator_login_password = random_password.sql_admin[0].result
  
  azuread_admin_login          = var.sql_azuread_admin_login
  azuread_admin_object_id      = var.sql_azuread_admin_object_id
  
  sku_name                     = local.database_config.sql_sku
  max_size_gb                  = local.database_config.sql_max_size_gb
  zone_redundant               = local.database_config.sql_zone_redundant
  
  backup_storage_redundancy    = local.database_config.backup_redundancy
  short_term_retention_days    = local.database_config.short_term_retention
  
  private_endpoint_enabled     = local.database_config.enable_private_endpoints
  private_endpoint_subnet_id   = data.terraform_remote_state.networking.outputs.subnet_private_endpoints_id
  private_dns_zone_ids         = []
  
  log_analytics_workspace_id   = try(data.terraform_remote_state.security.outputs.log_analytics_workspace_id, null)
  
  tags = local.common_tags
  
  depends_on = [module.database_rg]
}

# Store SQL password in Key Vault
resource "azurerm_key_vault_secret" "sql_admin_password" {
  count        = var.enable_sql_database ? 1 : 0
  name         = "sql-admin-password"
  value        = random_password.sql_admin[0].result
  key_vault_id = data.terraform_remote_state.security.outputs.key_vault_id
}

#=============================================================================
# Azure Redis Cache
#=============================================================================

resource "azurerm_redis_cache" "this" {
  count               = var.enable_redis_cache ? 1 : 0
  name                = "redis-${local.naming_prefix}-${local.location_short}"
  location            = var.location
  resource_group_name = module.database_rg.name
  capacity            = local.database_config.redis_capacity
  family              = local.database_config.redis_family
  sku_name            = local.database_config.redis_sku
  
  minimum_tls_version         = "1.2"
  public_network_access_enabled = !local.database_config.enable_private_endpoints
  redis_version               = "6"
  
  redis_configuration {
    enable_authentication           = true
    maxmemory_reserved             = local.database_config.redis_maxmemory_reserved
    maxmemory_delta                = local.database_config.redis_maxmemory_delta
    maxmemory_policy               = "allkeys-lru"
    notify_keyspace_events         = ""
  }

  tags = local.common_tags
}

# Redis private endpoint
resource "azurerm_private_endpoint" "redis" {
  count               = var.enable_redis_cache && local.database_config.enable_private_endpoints ? 1 : 0
  name                = "redis-${local.naming_prefix}-pe"
  location            = var.location
  resource_group_name = module.database_rg.name
  subnet_id           = data.terraform_remote_state.networking.outputs.subnet_private_endpoints_id

  private_service_connection {
    name                           = "redis-${local.naming_prefix}-psc"
    private_connection_resource_id = azurerm_redis_cache.this[0].id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  tags = local.common_tags
}

# Store Redis key in Key Vault
resource "azurerm_key_vault_secret" "redis_primary_key" {
  count        = var.enable_redis_cache ? 1 : 0
  name         = "redis-primary-key"
  value        = azurerm_redis_cache.this[0].primary_access_key
  key_vault_id = data.terraform_remote_state.security.outputs.key_vault_id
}

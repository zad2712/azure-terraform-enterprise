# Development Environment - Database Layer Configuration
# This file contains all database-related variables for the dev environment

# =============================================================================
# Environment Configuration
# =============================================================================
environment = "dev"
location    = "East US 2"

# State storage configuration
state_storage_account_name = "" # Will be set by pipeline
state_resource_group_name  = "" # Will be set by pipeline

# =============================================================================
# SQL Database Configuration
# =============================================================================
enable_sql_database = true
sql_database_name   = "appdb-dev"
sql_admin_login     = "sqladmin"

# Azure AD Admin Configuration
sql_azuread_admin_login     = "sql-admins@company.com"
sql_azuread_admin_object_id = "00000000-0000-0000-0000-000000000000" # Replace with actual object ID

# =============================================================================
# Redis Cache Configuration
# =============================================================================
enable_redis_cache = true

# =============================================================================
# PostgreSQL Configuration
# =============================================================================
enable_postgresql = false  # Disabled for dev to reduce costs

# =============================================================================
# MySQL Configuration
# =============================================================================
enable_mysql = false  # Disabled for dev to reduce costs

# =============================================================================
# Cosmos DB Configuration
# =============================================================================
enable_cosmos_db = false  # Disabled for dev to reduce costs

# =============================================================================
# Resource Tagging
# =============================================================================
tags = {
  Environment   = "dev"
  Owner        = "platform-team"
  CostCenter   = "engineering"
  Project      = "terraform-azure-enterprise"
  Workload     = "database"
  CreatedBy    = "terraform"
  CreatedDate  = "2025-01-15"
  
  # Cost management tags
  CostOptimized = "true"
  AutoShutdown  = "true"
  
  # Compliance tags
  Compliance    = "internal"
  DataClass     = "internal"
  
  # Operational tags
  Backup        = "not-required"
  Monitoring    = "basic"
  Support       = "business-hours"
}
# Development Environment - Database Layer
environment = "dev"
location    = "eastus"

# Project and Tagging
project_name           = "myapp"
cost_center            = "engineering"
owner_team             = "platform-team"
criticality            = "low"
data_classification    = "internal"

# Remote State
state_storage_account_name = "<STORAGE_ACCOUNT_NAME>"
state_resource_group_name  = "rg-terraform-state"

# SQL Database Configuration
enable_sql_database         = true
sql_database_name           = "app-db-dev"
sql_admin_login             = "sqladmin"
sql_azuread_admin_login     = ""  # Add your Azure AD admin
sql_azuread_admin_object_id = ""  # Add your Azure AD admin object ID

# Redis Cache Configuration
enable_redis_cache = true

# Other Databases (disabled for dev to save costs)
enable_postgresql = false
enable_mysql      = false
enable_cosmos_db  = false

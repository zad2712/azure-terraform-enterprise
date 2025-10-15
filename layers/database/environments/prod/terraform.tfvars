# Production Environment - Database Layer
environment = "prod"
location    = "eastus"

# Project and Tagging
project_name           = "myapp"
cost_center            = "engineering"
owner_team             = "platform-team"
criticality            = "critical"
data_classification    = "confidential"

# Remote State
state_storage_account_name = "<STORAGE_ACCOUNT_NAME>"
state_resource_group_name  = "rg-terraform-state"

# SQL Database Configuration
enable_sql_database         = true
sql_database_name           = "app-db-prod"
sql_admin_login             = "sqladmin"
sql_azuread_admin_login     = ""  # REQUIRED: Add Azure AD admin
sql_azuread_admin_object_id = ""  # REQUIRED: Add Azure AD admin object ID

# Redis Cache Configuration
enable_redis_cache = true

# Other Databases
enable_postgresql = false
enable_mysql      = false
enable_cosmos_db  = false

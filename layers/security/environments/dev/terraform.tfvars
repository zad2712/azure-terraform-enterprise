# Development Environment - Security Layer
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

# Key Vault Configuration
key_vault_sku = "standard"

# Allowed IP addresses for Key Vault access (dev can be permissive)
allowed_ip_addresses = []

# Managed Identities
enable_aks_workload_identity = true
enable_app_service_identity  = true

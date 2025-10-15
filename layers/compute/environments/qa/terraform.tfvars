#=============================================================================
# QA Environment - Compute Layer Configuration
#=============================================================================

# Environment Settings
environment = "qa"
location    = "eastus"

# Project and Tagging
project_name           = "myapp"
cost_center            = "engineering"
owner_team             = "platform-team"
criticality            = "medium"
data_classification    = "internal"

# Additional custom tags
additional_tags = {
  Terraform  = "true"
  Repository = "terraform-azure-enterprise"
}

# Remote State Configuration
state_storage_account_name = "<STORAGE_ACCOUNT_NAME>"
state_resource_group_name  = "rg-terraform-state"

# Availability Zones
availability_zones = ["1", "2", "3"]

#=============================================================================
# AKS Configuration
#=============================================================================

enable_aks             = true
aks_kubernetes_version = "1.28"
aks_dns_service_ip     = "172.16.0.10"
aks_service_cidr       = "172.16.0.0/16"

# AKS Admin Groups (Azure AD Object IDs)
aks_admin_group_object_ids = []  # Add your Azure AD group IDs

# Additional Node Pools
aks_additional_node_pools = {}

# Maintenance Window
aks_maintenance_window = {
  day   = "Sunday"
  hours = [2, 3, 4]
}

#=============================================================================
# App Service Configuration
#=============================================================================

enable_app_service = false

app_service_plan_sku = {
  tier = "Standard"
  size = "S1"
}

#=============================================================================
# VMSS Configuration
#=============================================================================

enable_vmss          = false
vmss_sku             = "Standard_D2s_v3"
vmss_instance_count  = 2
vmss_admin_username  = "azureuser"

#=============================================================================
# Azure Functions Configuration
#=============================================================================

enable_function_app         = false
function_app_runtime        = "node"
function_app_runtime_version = "18"

#=============================================================================
# Web App Configuration
#=============================================================================

enable_web_app                       = true
web_app_os_type                      = "Linux"
web_app_sku_name                     = "S1"
web_app_health_check_path            = "/health"
web_app_health_check_eviction_time   = 10

# Application Stack - Node.js example
web_app_application_stack = {
  node_version = "20-lts"
}

# App Settings
web_app_app_settings = {
  "NODE_ENV"                  = "qa"
  "WEBSITE_NODE_DEFAULT_VERSION" = "~20"
}

# Logging
web_app_detailed_error_messages   = false
web_app_failed_request_tracing    = false
web_app_enable_application_logs   = true
web_app_application_logs_level    = "Information"
web_app_enable_http_logs          = true
web_app_http_logs_retention_days  = 14
web_app_http_logs_retention_mb    = 50

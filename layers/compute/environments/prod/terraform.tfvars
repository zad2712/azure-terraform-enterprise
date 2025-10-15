#=============================================================================
# Production Environment - Compute Layer Configuration
#=============================================================================

# Environment Settings
environment = "prod"
location    = "eastus"

# Project and Tagging
project_name           = "myapp"
cost_center            = "engineering"
owner_team             = "platform-team"
criticality            = "critical"
data_classification    = "confidential"

# Additional custom tags
additional_tags = {
  Terraform         = "true"
  Repository        = "terraform-azure-enterprise"
  ComplianceScope   = "SOC2-TypeII"
  BackupRetention   = "90days"
}

# Remote State Configuration
state_storage_account_name = "<STORAGE_ACCOUNT_NAME>"
state_resource_group_name  = "rg-terraform-state"

# Availability Zones - Production uses all zones
availability_zones = ["1", "2", "3"]

#=============================================================================
# AKS Configuration
#=============================================================================

enable_aks             = true
aks_kubernetes_version = "1.28"  # Use stable production version
aks_dns_service_ip     = "172.16.0.10"
aks_service_cidr       = "172.16.0.0/16"

# AKS Admin Groups (Azure AD Object IDs)
# CRITICAL: Add your production admin group IDs
aks_admin_group_object_ids = []  # Add your Azure AD group IDs

# Additional Node Pools - Production workload pools
aks_additional_node_pools = {
  user = {
    name                = "user"
    vm_size             = "Standard_D8s_v3"  # Larger for production
    node_count          = 3
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    max_pods            = 110
    os_disk_size_gb     = 256  # Larger disk for production
    os_disk_type        = "Premium_LRS"
    subnet_id           = ""  # Will be populated from remote state
    availability_zones  = ["1", "2", "3"]
    node_labels         = { "workload" = "user", "environment" = "production" }
    node_taints         = []
    mode                = "User"
    priority            = "Regular"
    spot_max_price      = -1
    max_surge           = "33%"
  }
  # Optional: Add spot instance pool for non-critical workloads
  spot = {
    name                = "spot"
    vm_size             = "Standard_D4s_v3"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 0
    max_count           = 5
    max_pods            = 110
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    subnet_id           = ""
    availability_zones  = ["1", "2", "3"]
    node_labels         = { "workload" = "batch", "priority" = "spot" }
    node_taints         = ["spot=true:NoSchedule"]
    mode                = "User"
    priority            = "Spot"
    spot_max_price      = 0.05  # Max price per hour
    max_surge           = "33%"
  }
}

# Maintenance Window - Production maintenance during low-traffic period
aks_maintenance_window = {
  day   = "Sunday"
  hours = [1, 2, 3, 4]  # 1 AM - 5 AM maintenance window
}

#=============================================================================
# App Service Configuration
#=============================================================================

enable_app_service = true

app_service_plan_sku = {
  tier = "PremiumV3"  # Production-grade with auto-scaling
  size = "P1v3"
}

#=============================================================================
# VMSS Configuration
#=============================================================================

enable_vmss          = true  # Enable for legacy workloads
vmss_sku             = "Standard_D4s_v3"
vmss_instance_count  = 3
vmss_admin_username  = "azureuser"

#=============================================================================
# Azure Functions Configuration
#=============================================================================

enable_function_app         = true
function_app_runtime        = "node"
function_app_runtime_version = "20"  # Latest LTS version

#=============================================================================
# Web App Configuration
#=============================================================================

enable_web_app                       = true
web_app_os_type                      = "Linux"
web_app_sku_name                     = "P1v3"  # Production premium SKU
web_app_health_check_path            = "/health"
web_app_health_check_eviction_time   = 10

# Application Stack - Node.js example (LTS version for production)
web_app_application_stack = {
  node_version = "20-lts"
}

# App Settings - Production configuration
web_app_app_settings = {
  "NODE_ENV"                     = "production"
  "WEBSITE_NODE_DEFAULT_VERSION" = "~20"
  "WEBSITE_HTTPLOGGING_RETENTION_DAYS" = "90"
}

# Logging - Production logging configuration
web_app_detailed_error_messages   = false  # Disabled for security
web_app_failed_request_tracing    = false  # Disabled for security
web_app_enable_application_logs   = true
web_app_application_logs_level    = "Warning"  # Only warnings and errors
web_app_enable_http_logs          = true
web_app_http_logs_retention_days  = 90  # Longer retention for production
web_app_http_logs_retention_mb    = 100  # Larger size for production

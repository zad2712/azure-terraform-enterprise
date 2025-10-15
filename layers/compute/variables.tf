#=============================================================================
# Environment Variables
#=============================================================================

variable "environment" {
  description = "Environment name (dev, qa, uat, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, qa, uat, or prod."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

#=============================================================================
# Project and Tagging Variables
#=============================================================================

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}

variable "owner_team" {
  description = "Team responsible for resources"
  type        = string
}

variable "criticality" {
  description = "Criticality level"
  type        = string
  default     = "medium"
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
}

variable "additional_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

#=============================================================================
# Remote State Variables
#=============================================================================

variable "state_storage_account_name" {
  description = "Storage account name for remote state"
  type        = string
}

variable "state_resource_group_name" {
  description = "Resource group name for state storage"
  type        = string
  default     = "rg-terraform-state"
}

variable "enable_security_integration" {
  description = "Enable integration with security layer (for Key Vault, Log Analytics)"
  type        = bool
  default     = true
}

#=============================================================================
# General Compute Variables
#=============================================================================

variable "availability_zones" {
  description = "Availability zones for resources"
  type        = list(string)
  default     = ["1", "2", "3"]
}

#=============================================================================
# AKS Variables
#=============================================================================

variable "enable_aks" {
  description = "Enable AKS cluster deployment"
  type        = bool
  default     = true
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.28"
}

variable "aks_dns_service_ip" {
  description = "DNS service IP for AKS"
  type        = string
  default     = "172.16.0.10"
}

variable "aks_service_cidr" {
  description = "Service CIDR for AKS"
  type        = string
  default     = "172.16.0.0/16"
}

variable "aks_admin_group_object_ids" {
  description = "Azure AD group object IDs for AKS cluster admin"
  type        = list(string)
  default     = []
}

variable "aks_additional_node_pools" {
  description = "Additional node pools for AKS"
  type = map(object({
    name                = string
    vm_size             = string
    node_count          = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    max_pods            = number
    os_disk_size_gb     = number
    os_disk_type        = string
    subnet_id           = string
    availability_zones  = list(string)
    node_labels         = map(string)
    node_taints         = list(string)
    mode                = string
    priority            = string
    spot_max_price      = number
    max_surge           = string
  }))
  default = {}
}

variable "aks_maintenance_window" {
  description = "Maintenance window for AKS"
  type = object({
    day   = string
    hours = list(number)
  })
  default = {
    day   = "Saturday"
    hours = [2, 3, 4]
  }
}

#=============================================================================
# App Service Variables
#=============================================================================

variable "enable_app_service" {
  description = "Enable App Service deployment"
  type        = bool
  default     = false
}

variable "app_service_plan_sku" {
  description = "SKU for App Service Plan"
  type = object({
    tier = string
    size = string
  })
  default = {
    tier = "Standard"
    size = "S1"
  }
}

#=============================================================================
# Virtual Machine Scale Set Variables
#=============================================================================

variable "enable_vmss" {
  description = "Enable VMSS deployment"
  type        = bool
  default     = false
}

variable "vmss_sku" {
  description = "VM SKU for scale set"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vmss_instance_count" {
  description = "Number of VM instances"
  type        = number
  default     = 2
}

variable "vmss_admin_username" {
  description = "Admin username for VMSS"
  type        = string
  default     = "azureuser"
}

#=============================================================================
# Azure Functions Variables
#=============================================================================

variable "enable_function_app" {
  description = "Enable Azure Functions deployment"
  type        = bool
  default     = false
}

variable "function_app_runtime" {
  description = "Runtime for Azure Functions"
  type        = string
  default     = "node"
}

variable "function_app_runtime_version" {
  description = "Runtime version"
  type        = string
  default     = "18"
}
#=============================================================================
# App Service Variables
#=============================================================================

variable "app_service_os_type" {
  description = "OS type for App Service (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.app_service_os_type)
    error_message = "OS type must be either Linux or Windows."
  }
}

variable "app_service_health_check_path" {
  description = "Health check path for App Service"
  type        = string
  default     = "/"
}

variable "app_service_application_stack" {
  description = "Application stack configuration for App Service"
  type        = map(string)
  default     = null
}

variable "app_service_ip_restrictions" {
  description = "IP restriction rules for App Service"
  type = list(object({
    name                      = string
    priority                  = number
    action                    = string
    ip_address                = optional(string)
    virtual_network_subnet_id = optional(string)
  }))
  default = []
}

variable "app_service_app_settings" {
  description = "Application settings for App Service"
  type        = map(string)
  default     = {}
}

variable "app_service_connection_strings" {
  description = "Connection strings for App Service"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default   = []
  sensitive = true
}

#=============================================================================
# App Service Variables
#=============================================================================

variable "enable_app_service" {
  description = "Enable App Service deployment"
  type        = bool
  default     = false
}

variable "app_service_os_type" {
  description = "OS type for App Service (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.app_service_os_type)
    error_message = "App Service OS type must be Linux or Windows."
  }
}

variable "enable_app_service_vnet_integration" {
  description = "Enable VNet integration for App Service"
  type        = bool
  default     = false
}

variable "app_service_websockets_enabled" {
  description = "Enable WebSockets for App Service"
  type        = bool
  default     = false
}

variable "app_service_health_check_path" {
  description = "Health check path for App Service"
  type        = string
  default     = null
}

# Application Stack Configuration
variable "app_service_docker_image" {
  description = "Docker image name for Linux App Service"
  type        = string
  default     = null
}

variable "app_service_docker_registry_url" {
  description = "Docker registry URL"
  type        = string
  default     = "https://index.docker.io"
}

variable "app_service_dotnet_version" {
  description = ".NET version for App Service"
  type        = string
  default     = null
}

variable "app_service_java_version" {
  description = "Java version for App Service"
  type        = string
  default     = null
}

variable "app_service_node_version" {
  description = "Node.js version for App Service"
  type        = string
  default     = null
}

variable "app_service_php_version" {
  description = "PHP version for App Service"
  type        = string
  default     = null
}

variable "app_service_python_version" {
  description = "Python version for App Service"
  type        = string
  default     = null
}

variable "app_service_windows_stack" {
  description = "Windows stack for App Service (dotnet, node, php, python)"
  type        = string
  default     = null
}

# Security and Networking
variable "app_service_ip_restrictions" {
  description = "IP restriction rules for App Service"
  type = list(object({
    name                      = string
    priority                  = number
    action                    = string
    ip_address                = optional(string)
    virtual_network_subnet_id = optional(string)
    service_tag               = optional(string)
  }))
  default = []
}

variable "app_service_cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = null
}

variable "app_service_cors_support_credentials" {
  description = "Support credentials for CORS"
  type        = bool
  default     = false
}

# App Settings and Connection Strings
variable "app_service_app_settings" {
  description = "App settings for App Service"
  type        = map(string)
  default     = {}
}

variable "app_service_connection_strings" {
  description = "Connection strings for App Service"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
  sensitive = true
}

#=============================================================================
# Web App Configuration
#=============================================================================

variable "enable_web_app" {
  description = "Enable Web App deployment"
  type        = bool
  default     = false
}

variable "web_app_os_type" {
  description = "Operating System type for Web App (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.web_app_os_type)
    error_message = "OS type must be either Linux or Windows."
  }
}

variable "web_app_sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "P1v3"
}

variable "web_app_health_check_path" {
  description = "Health check path for Web App"
  type        = string
  default     = "/health"
}

variable "web_app_health_check_eviction_time" {
  description = "Health check eviction time in minutes"
  type        = number
  default     = 10
}

variable "web_app_identity_type" {
  description = "Type of managed identity for Web App"
  type        = string
  default     = "SystemAssigned"
}

variable "web_app_identity_ids" {
  description = "List of User Assigned Identity IDs for Web App"
  type        = list(string)
  default     = []
}

variable "web_app_application_stack" {
  description = "Application stack configuration for Web App"
  type        = any
  default     = null
}

variable "web_app_app_settings" {
  description = "Application settings for Web App"
  type        = map(string)
  default     = {}
}

variable "web_app_connection_strings" {
  description = "Connection strings for Web App"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default   = []
  sensitive = true
}

variable "web_app_detailed_error_messages" {
  description = "Enable detailed error messages for Web App"
  type        = bool
  default     = false
}

variable "web_app_failed_request_tracing" {
  description = "Enable failed request tracing for Web App"
  type        = bool
  default     = false
}

variable "web_app_enable_application_logs" {
  description = "Enable application logs for Web App"
  type        = bool
  default     = true
}

variable "web_app_application_logs_level" {
  description = "Application logs level for Web App"
  type        = string
  default     = "Information"
}

variable "web_app_enable_http_logs" {
  description = "Enable HTTP logs for Web App"
  type        = bool
  default     = true
}

variable "web_app_http_logs_retention_days" {
  description = "HTTP logs retention in days for Web App"
  type        = number
  default     = 7
}

variable "web_app_http_logs_retention_mb" {
  description = "HTTP logs retention in MB for Web App"
  type        = number
  default     = 35
}

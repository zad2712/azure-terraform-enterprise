# App Service Plan Variables
variable "service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "os_type" {
  description = "OS type for App Service Plan (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be Linux or Windows."
  }
}

variable "sku_name" {
  description = "SKU name for App Service Plan (e.g., B1, S1, P1v3)"
  type        = string
  default     = "B1"
}

variable "worker_count" {
  description = "Number of workers for App Service Plan"
  type        = number
  default     = 1
}

variable "per_site_scaling_enabled" {
  description = "Enable per-site scaling"
  type        = bool
  default     = false
}

variable "zone_balancing_enabled" {
  description = "Enable zone balancing for high availability"
  type        = bool
  default     = false
}

variable "maximum_elastic_worker_count" {
  description = "Maximum number of elastic workers"
  type        = number
  default     = null
}

# App Service Configuration
variable "https_only" {
  description = "Force HTTPS only"
  type        = bool
  default     = true
}

variable "client_affinity_enabled" {
  description = "Enable client affinity (sticky sessions)"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "vnet_integration_subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

# Identity
variable "identity_type" {
  description = "Type of managed identity (SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "List of user-assigned identity IDs"
  type        = list(string)
  default     = []
}

# Site Configuration
variable "always_on" {
  description = "Keep app always on"
  type        = bool
  default     = true
}

variable "ftps_state" {
  description = "FTPS state (Disabled, FtpsOnly, AllAllowed)"
  type        = string
  default     = "FtpsOnly"
}

variable "http2_enabled" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "vnet_route_all_enabled" {
  description = "Route all traffic through VNet"
  type        = bool
  default     = false
}

variable "websockets_enabled" {
  description = "Enable WebSockets"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "Time in minutes before unhealthy instance is removed"
  type        = number
  default     = 10
}

# Application Stack - Linux
variable "docker_image_name" {
  description = "Docker image name for Linux apps"
  type        = string
  default     = null
}

variable "docker_registry_url" {
  description = "Docker registry URL"
  type        = string
  default     = null
}

variable "dotnet_version" {
  description = ".NET version"
  type        = string
  default     = null
}

variable "java_version" {
  description = "Java version"
  type        = string
  default     = null
}

variable "node_version" {
  description = "Node.js version"
  type        = string
  default     = null
}

variable "php_version" {
  description = "PHP version"
  type        = string
  default     = null
}

variable "python_version" {
  description = "Python version"
  type        = string
  default     = null
}

# Application Stack - Windows
variable "windows_current_stack" {
  description = "Current stack for Windows apps (dotnet, node, php, python)"
  type        = string
  default     = null
}

# IP Restrictions
variable "ip_restrictions" {
  description = "List of IP restriction rules"
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

# CORS
variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = null
}

variable "cors_support_credentials" {
  description = "Support credentials for CORS"
  type        = bool
  default     = false
}

# App Settings
variable "app_settings" {
  description = "Map of app settings"
  type        = map(string)
  default     = {}
}

variable "connection_strings" {
  description = "List of connection strings"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}

# Logging
variable "detailed_error_messages" {
  description = "Enable detailed error messages"
  type        = bool
  default     = true
}

variable "failed_request_tracing" {
  description = "Enable failed request tracing"
  type        = bool
  default     = true
}

variable "app_log_level" {
  description = "Application log level"
  type        = string
  default     = "Information"
}

variable "http_logs_retention_days" {
  description = "HTTP logs retention in days"
  type        = number
  default     = 7
}

variable "http_logs_retention_mb" {
  description = "HTTP logs retention in MB"
  type        = number
  default     = 35
}

# Application Insights
variable "application_insights_key" {
  description = "Application Insights connection string"
  type        = string
  default     = null
  sensitive   = true
}

# Deployment Slots
variable "enable_staging_slot" {
  description = "Enable staging deployment slot"
  type        = bool
  default     = false
}

# Monitoring
variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

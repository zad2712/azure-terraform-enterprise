# Basic Configuration
variable "name" {
  description = "Name of the web app"
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

# Service Plan Configuration
variable "service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "os_type" {
  description = "Operating System type (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either Linux or Windows."
  }
}

variable "sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "P1v3"
}

variable "zone_redundant" {
  description = "Enable zone redundancy for the App Service Plan"
  type        = bool
  default     = false
}

# Web App Configuration
variable "https_only" {
  description = "Require HTTPS only"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "always_on" {
  description = "Keep the app always on"
  type        = bool
  default     = true
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

variable "ftps_state" {
  description = "FTPS state (Disabled, FtpsOnly, AllAllowed)"
  type        = string
  default     = "Disabled"
}

# Networking
variable "vnet_integration_subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

variable "vnet_route_all_enabled" {
  description = "Route all outbound traffic through VNet"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = null
}

variable "health_check_eviction_time" {
  description = "Health check eviction time in minutes"
  type        = number
  default     = 10
}

# Identity
variable "identity_type" {
  description = "Type of managed identity (SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "List of User Assigned Identity IDs"
  type        = list(string)
  default     = []
}

# Application Stack
variable "application_stack" {
  description = "Application stack configuration"
  type        = any
  default     = null
}

# IP Restrictions
variable "ip_restrictions" {
  description = "List of IP restrictions"
  type = list(object({
    name                      = string
    ip_address                = optional(string)
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
    action                    = optional(string)
    priority                  = optional(number)
  }))
  default = []
}

# CORS
variable "cors_allowed_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = null
}

variable "cors_support_credentials" {
  description = "CORS support credentials"
  type        = bool
  default     = false
}

# App Settings
variable "app_settings" {
  description = "Application settings"
  type        = map(string)
  default     = {}
}

# Connection Strings
variable "connection_strings" {
  description = "Connection strings"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
  sensitive = true
}

# Logging
variable "detailed_error_messages" {
  description = "Enable detailed error messages"
  type        = bool
  default     = false
}

variable "failed_request_tracing" {
  description = "Enable failed request tracing"
  type        = bool
  default     = false
}

variable "enable_application_logs" {
  description = "Enable application logs"
  type        = bool
  default     = true
}

variable "application_logs_level" {
  description = "Application logs level"
  type        = string
  default     = "Information"
}

variable "enable_http_logs" {
  description = "Enable HTTP logs"
  type        = bool
  default     = true
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

# Private Endpoint
variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs"
  type        = list(string)
  default     = []
}

# Monitoring
variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

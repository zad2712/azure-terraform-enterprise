variable "name" {
  description = "Name of the Application Insights instance"
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

variable "workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "application_type" {
  description = "Application type"
  type        = string
  default     = "web"
}

variable "retention_in_days" {
  description = "Data retention in days"
  type        = number
  default     = 90
}

variable "daily_data_cap_in_gb" {
  description = "Daily data cap in GB"
  type        = number
  default     = 100
}

variable "daily_data_cap_notifications_disabled" {
  description = "Disable daily data cap notifications"
  type        = bool
  default     = false
}

variable "sampling_percentage" {
  description = "Sampling percentage (0-100)"
  type        = number
  default     = 100
}

variable "disable_ip_masking" {
  description = "Disable IP masking"
  type        = bool
  default     = false
}

variable "internet_ingestion_enabled" {
  description = "Enable internet ingestion"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Enable internet query"
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Disable local authentication"
  type        = bool
  default     = false
}

variable "web_tests" {
  description = "Map of web tests for availability monitoring"
  type = map(object({
    name          = string
    url           = string
    geo_locations = list(string)
    frequency     = number
    timeout       = number
    enabled       = bool
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

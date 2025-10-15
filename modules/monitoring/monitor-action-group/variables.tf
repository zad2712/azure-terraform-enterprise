variable "name" {
  description = "Name of the action group"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "short_name" {
  description = "Short name (max 12 characters)"
  type        = string

  validation {
    condition     = length(var.short_name) <= 12
    error_message = "Short name must be 12 characters or less."
  }
}

variable "enabled" {
  description = "Enable the action group"
  type        = bool
  default     = true
}

variable "email_receivers" {
  description = "List of email receivers"
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool)
  }))
  default = []
}

variable "sms_receivers" {
  description = "List of SMS receivers"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "webhook_receivers" {
  description = "List of webhook receivers"
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = optional(bool)
  }))
  default = []
}

variable "azure_app_push_receivers" {
  description = "List of Azure app push receivers"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "logic_app_receivers" {
  description = "List of Logic App receivers"
  type = list(object({
    name                    = string
    resource_id             = string
    callback_url            = string
    use_common_alert_schema = optional(bool)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

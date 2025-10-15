variable "name" {
  description = "Name of the virtual network"
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

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  
  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be specified."
  }
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = []
}

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "diagnostic_logs" {
  description = "List of log categories to enable"
  type        = list(string)
  default = [
    "VMProtectionAlerts"
  ]
}

variable "diagnostic_metrics" {
  description = "List of metric categories to enable"
  type        = list(string)
  default = [
    "AllMetrics"
  ]
}

variable "enable_flow_logs" {
  description = "Enable NSG flow logs"
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher"
  type        = string
  default     = null
}

variable "network_watcher_resource_group_name" {
  description = "Resource group of Network Watcher"
  type        = string
  default     = null
}

variable "nsg_id_for_flow_logs" {
  description = "NSG ID for flow logs"
  type        = string
  default     = null
}

variable "flow_logs_storage_account_id" {
  description = "Storage account ID for flow logs"
  type        = string
  default     = null
}

variable "flow_logs_retention_days" {
  description = "Retention period for flow logs"
  type        = number
  default     = 30
}

variable "enable_traffic_analytics" {
  description = "Enable traffic analytics"
  type        = bool
  default     = true
}

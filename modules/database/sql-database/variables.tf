variable "server_name" {
  description = "SQL Server name"
  type        = string
}

variable "database_name" {
  description = "SQL Database name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "server_version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
}

variable "administrator_login" {
  description = "Administrator login"
  type        = string
  sensitive   = true
}

variable "administrator_login_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "azuread_admin_login" {
  description = "Azure AD admin login"
  type        = string
}

variable "azuread_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
}

variable "sku_name" {
  description = "Database SKU"
  type        = string
  default     = "GP_S_Gen5_2"
}

variable "max_size_gb" {
  description = "Max database size in GB"
  type        = number
  default     = 32
}

variable "collation" {
  description = "Database collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "zone_redundant" {
  description = "Enable zone redundancy"
  type        = bool
  default     = false
}

variable "read_scale" {
  description = "Enable read scale-out"
  type        = bool
  default     = false
}

variable "auto_pause_delay_in_minutes" {
  description = "Auto-pause delay for serverless"
  type        = number
  default     = 60
}

variable "min_capacity" {
  description = "Minimum capacity for serverless"
  type        = number
  default     = 0.5
}

variable "backup_storage_redundancy" {
  description = "Backup storage redundancy"
  type        = string
  default     = "Geo"
}

variable "short_term_retention_days" {
  description = "Short-term backup retention"
  type        = number
  default     = 7
}

variable "ltr_weekly_retention" {
  description = "Long-term weekly retention"
  type        = string
  default     = "P1W"
}

variable "ltr_monthly_retention" {
  description = "Long-term monthly retention"
  type        = string
  default     = "P1M"
}

variable "ltr_yearly_retention" {
  description = "Long-term yearly retention"
  type        = string
  default     = "P1Y"
}

variable "ltr_week_of_year" {
  description = "Week of year for yearly backup"
  type        = number
  default     = 1
}

variable "threat_detection_emails" {
  description = "Emails for threat detection"
  type        = list(string)
  default     = []
}

variable "threat_detection_retention_days" {
  description = "Threat detection retention"
  type        = number
  default     = 30
}

variable "threat_detection_storage_endpoint" {
  description = "Storage endpoint for threat detection"
  type        = string
  default     = null
}

variable "threat_detection_storage_key" {
  description = "Storage key for threat detection"
  type        = string
  default     = null
  sensitive   = true
}

variable "enable_tde" {
  description = "Enable TDE with customer-managed key"
  type        = bool
  default     = false
}

variable "tde_key_vault_key_id" {
  description = "Key Vault key ID for TDE"
  type        = string
  default     = null
}

variable "firewall_rules" {
  description = "Firewall rules"
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = {}
}

variable "vnet_rules" {
  description = "VNet rules (subnet IDs)"
  type        = map(string)
  default     = {}
}

variable "private_endpoint_enabled" {
  description = "Enable private endpoint"
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "Private endpoint subnet ID"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

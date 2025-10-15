variable "name" {
  description = "Storage account name (3-24 chars, lowercase, numbers only)"
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

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Replication type"
  type        = string
  default     = "GRS"
}

variable "account_kind" {
  description = "Account kind"
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "Access tier"
  type        = string
  default     = "Hot"
}

variable "allow_nested_items_to_be_public" {
  description = "Allow public access to blobs"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Enable shared access key"
  type        = bool
  default     = true
}

variable "private_endpoint_only" {
  description = "Disable public network access"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = true
}

variable "enable_change_feed" {
  description = "Enable change feed"
  type        = bool
  default     = false
}

variable "enable_last_access_time" {
  description = "Enable last access time tracking"
  type        = bool
  default     = false
}

variable "blob_soft_delete_retention_days" {
  description = "Blob soft delete retention"
  type        = number
  default     = 7
}

variable "container_soft_delete_retention_days" {
  description = "Container soft delete retention"
  type        = number
  default     = 7
}

variable "cors_rules" {
  description = "CORS rules"
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

variable "network_rules_default_action" {
  description = "Network rules default action"
  type        = string
  default     = "Deny"
}

variable "network_rules_bypass" {
  description = "Network rules bypass"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "allowed_ip_addresses" {
  description = "Allowed IP addresses"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Allowed subnet IDs"
  type        = list(string)
  default     = []
}

variable "enable_private_endpoint" {
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

variable "lifecycle_rules" {
  description = "Lifecycle management rules"
  type = list(object({
    name                          = string
    enabled                       = bool
    prefix_match                  = list(string)
    blob_types                    = list(string)
    tier_to_cool_after_days       = number
    tier_to_archive_after_days    = number
    delete_after_days             = number
    snapshot_delete_after_days    = number
  }))
  default = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

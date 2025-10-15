variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "cost_center" {
  description = "Cost center"
  type        = string
}

variable "owner_team" {
  description = "Owner team"
  type        = string
}

variable "criticality" {
  description = "Criticality level"
  type        = string
  default     = "high"
}

variable "data_classification" {
  description = "Data classification"
  type        = string
  default     = "confidential"
}

variable "additional_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "state_storage_account_name" {
  description = "Storage account for remote state"
  type        = string
}

variable "state_resource_group_name" {
  description = "Resource group for state storage"
  type        = string
  default     = "rg-terraform-state"
}

variable "enable_sql_database" {
  description = "Enable SQL Database"
  type        = bool
  default     = false
}

variable "sql_database_name" {
  description = "SQL database name"
  type        = string
  default     = "app-db"
}

variable "sql_admin_login" {
  description = "SQL admin login"
  type        = string
  default     = "sqladmin"
}

variable "sql_azuread_admin_login" {
  description = "Azure AD admin login"
  type        = string
  default     = ""
}

variable "sql_azuread_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
  default     = ""
}

variable "enable_redis_cache" {
  description = "Enable Redis Cache"
  type        = bool
  default     = false
}

variable "enable_postgresql" {
  description = "Enable PostgreSQL"
  type        = bool
  default     = false
}

variable "enable_mysql" {
  description = "Enable MySQL"
  type        = bool
  default     = false
}

variable "enable_cosmos_db" {
  description = "Enable Cosmos DB"
  type        = bool
  default     = false
}

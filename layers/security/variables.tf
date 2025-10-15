# Environment Variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# Project and Tagging
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
  default     = "medium"
}

variable "data_classification" {
  description = "Data classification"
  type        = string
  default     = "internal"
}

variable "additional_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

# Remote State
variable "state_storage_account_name" {
  description = "Storage account for remote state"
  type        = string
}

variable "state_resource_group_name" {
  description = "Resource group for state storage"
  type        = string
  default     = "rg-terraform-state"
}

# Key Vault
variable "key_vault_sku" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"
}

variable "allowed_ip_addresses" {
  description = "Allowed IP addresses for Key Vault"
  type        = list(string)
  default     = []
}

# Managed Identities
variable "enable_aks_workload_identity" {
  description = "Enable managed identity for AKS workloads"
  type        = bool
  default     = true
}

variable "enable_app_service_identity" {
  description = "Enable managed identity for App Services"
  type        = bool
  default     = true
}

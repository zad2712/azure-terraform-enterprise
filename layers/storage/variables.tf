# Environment Variables
variable "environment" { description = "Environment name"; type = string }
variable "location" { description = "Azure region"; type = string; default = "eastus" }
variable "project_name" { description = "Project name"; type = string }
variable "cost_center" { description = "Cost center"; type = string }
variable "owner_team" { description = "Owner team"; type = string }
variable "criticality" { description = "Criticality level"; type = string; default = "medium" }
variable "data_classification" { description = "Data classification"; type = string; default = "internal" }
variable "additional_tags" { description = "Additional tags"; type = map(string); default = {} }
variable "state_storage_account_name" { description = "Storage account for remote state"; type = string }
variable "state_resource_group_name" { description = "Resource group for state storage"; type = string; default = "rg-terraform-state" }

variable "name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = can(regex("^rg-[a-z0-9-]+$", var.name))
    error_message = "Resource group name must start with 'rg-' and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "Azure region where the resource group will be created"
  type        = string
}

variable "tags" {
  description = "Standard tags to apply to the resource group"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to merge with standard tags"
  type        = map(string)
  default     = {}
}

variable "lock_level" {
  description = "Level of management lock (CanNotDelete or ReadOnly). Set to null for no lock"
  type        = string
  default     = null

  validation {
    condition     = var.lock_level == null || contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "lock_level must be either 'CanNotDelete', 'ReadOnly', or null."
  }
}

variable "lock_notes" {
  description = "Notes about the management lock"
  type        = string
  default     = "Resource group locked by Terraform"
}

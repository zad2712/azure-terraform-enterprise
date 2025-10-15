#=============================================================================
# Environment Variables
#=============================================================================

variable "environment" {
  description = "Environment name (dev, qa, uat, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, qa, uat, or prod."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short name for Azure region (used in resource naming)"
  type        = string
  default     = "eus"
}

#=============================================================================
# Project and Tagging Variables
#=============================================================================

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "cost_center" {
  description = "Cost center for billing and chargeback"
  type        = string
}

variable "owner_team" {
  description = "Team responsible for the resources"
  type        = string
}

variable "criticality" {
  description = "Criticality level of the environment"
  type        = string
  default     = "medium"
  
  validation {
    condition     = contains(["low", "medium", "high", "critical"], var.criticality)
    error_message = "Criticality must be low, medium, high, or critical."
  }
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
  
  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be public, internal, confidential, or restricted."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

#=============================================================================
# Networking Variables
#=============================================================================

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)

  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "At least one address space must be specified."
  }
}

variable "dns_servers" {
  description = "List of DNS servers for the VNet (empty for Azure default)"
  type        = list(string)
  default     = []
}

#=============================================================================
# Subnet CIDR Variables
#=============================================================================

variable "subnet_management_cidr" {
  description = "CIDR block for management subnet (jump boxes, DevOps agents)"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_management_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "subnet_appgw_cidr" {
  description = "CIDR block for Application Gateway subnet"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_appgw_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "subnet_aks_system_cidr" {
  description = "CIDR block for AKS system node pool subnet"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_aks_system_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "subnet_aks_user_cidr" {
  description = "CIDR block for AKS user node pool subnet"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_aks_user_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "subnet_private_endpoints_cidr" {
  description = "CIDR block for private endpoints subnet"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_private_endpoints_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "subnet_database_cidr" {
  description = "CIDR block for database subnet with service delegation"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_database_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "subnet_app_service_cidr" {
  description = "CIDR block for App Service VNet integration subnet"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_app_service_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

#=============================================================================
# Security Variables
#=============================================================================

variable "allowed_management_ips" {
  description = "IP address or CIDR block allowed for management access (SSH/RDP)"
  type        = string
  default     = "*"
}

#=============================================================================
# Monitoring Variables
#=============================================================================

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics (optional)"
  type        = string
  default     = null
}

#=============================================================================
# Feature Flags
#=============================================================================

variable "enable_ddos_protection" {
  description = "Enable DDoS Protection Standard (additional cost)"
  type        = bool
  default     = false
}

variable "enable_network_watcher" {
  description = "Enable Network Watcher flow logs and traffic analytics"
  type        = bool
  default     = true
}

variable "enable_bastion" {
  description = "Deploy Azure Bastion for secure RDP/SSH access"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Deploy VPN Gateway for hybrid connectivity"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Deploy NAT Gateway for outbound internet connectivity"
  type        = bool
  default     = false
}

#=============================================================================
# QA Environment Configuration
#=============================================================================

# Environment Settings
environment    = "qa"
location       = "eastus"
location_short = "eus"

# Project and Tagging
project_name           = "myapp"
cost_center            = "engineering"
owner_team             = "platform-team"
criticality            = "medium"
data_classification    = "internal"

# Additional custom tags
additional_tags = {
  Terraform = "true"
  Repository = "terraform-azure-enterprise"
}

# Networking Configuration - Different address space from dev
vnet_address_space = ["10.1.0.0/16"]

# DNS Servers (leave empty for Azure default DNS)
dns_servers = []

# Subnet Configuration
subnet_management_cidr        = "10.1.1.0/24"
subnet_appgw_cidr            = "10.1.2.0/24"
subnet_aks_system_cidr       = "10.1.10.0/24"
subnet_aks_user_cidr         = "10.1.11.0/23"
subnet_private_endpoints_cidr = "10.1.20.0/24"
subnet_database_cidr         = "10.1.30.0/24"
subnet_app_service_cidr      = "10.1.40.0/24"

# Security - Management Access
# More restrictive than dev - only from internal networks
allowed_management_ips = "10.0.0.0/8"

# Feature Flags
enable_ddos_protection = false  # Optional for QA
enable_network_watcher = true   # Important for troubleshooting
enable_bastion         = false  # Optional
enable_vpn_gateway     = false  # Only if hybrid connectivity needed
enable_nat_gateway     = false  # Optional

# Custom Routes (empty for qa - add if needed)
custom_routes = []

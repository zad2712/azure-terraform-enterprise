#=============================================================================
# Development Environment Configuration
#=============================================================================

# Environment Settings
environment    = "dev"
location       = "eastus"
location_short = "eus"

# Project and Tagging
project_name           = "myapp"
cost_center            = "engineering"
owner_team             = "platform-team"
criticality            = "low"
data_classification    = "internal"

# Additional custom tags
additional_tags = {
  Terraform = "true"
  Repository = "terraform-azure-enterprise"
}

# Networking Configuration
vnet_address_space = ["10.0.0.0/16"]

# DNS Servers (leave empty for Azure default DNS)
dns_servers = []

# Subnet Configuration
subnet_management_cidr        = "10.0.1.0/24"
subnet_appgw_cidr            = "10.0.2.0/24"
subnet_aks_system_cidr       = "10.0.10.0/24"
subnet_aks_user_cidr         = "10.0.11.0/23"
subnet_private_endpoints_cidr = "10.0.20.0/24"
subnet_database_cidr         = "10.0.30.0/24"
subnet_app_service_cidr      = "10.0.40.0/24"

# Security - Management Access
# For dev, can be more permissive. Production should be restricted to corporate IPs
allowed_management_ips = "*"

# Feature Flags
enable_ddos_protection = false  # Not needed for dev, save costs
enable_network_watcher = true   # Useful for troubleshooting
enable_bastion         = false  # Optional, enable if needed for secure access
enable_vpn_gateway     = false  # Only if hybrid connectivity needed
enable_nat_gateway     = false  # Optional, for controlled outbound connectivity

# Custom Routes (empty for dev - add if needed)
custom_routes = []

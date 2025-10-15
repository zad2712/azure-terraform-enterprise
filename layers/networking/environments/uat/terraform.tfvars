#=============================================================================
# UAT Environment Configuration
#=============================================================================

# Environment Settings
environment    = "uat"
location       = "eastus"
location_short = "eus"

# Project and Tagging
project_name           = "myapp"
cost_center            = "engineering"
owner_team             = "platform-team"
criticality            = "high"
data_classification    = "confidential"

# Additional custom tags
additional_tags = {
  Terraform = "true"
  Repository = "terraform-azure-enterprise"
}

# Networking Configuration - Different address space
vnet_address_space = ["10.2.0.0/16"]

# DNS Servers (consider custom DNS for UAT)
dns_servers = []

# Subnet Configuration
subnet_management_cidr        = "10.2.1.0/24"
subnet_appgw_cidr            = "10.2.2.0/24"
subnet_aks_system_cidr       = "10.2.10.0/24"
subnet_aks_user_cidr         = "10.2.11.0/23"
subnet_private_endpoints_cidr = "10.2.20.0/24"
subnet_database_cidr         = "10.2.30.0/24"
subnet_app_service_cidr      = "10.2.40.0/24"

# Security - Management Access
# Restricted to internal corporate network only
allowed_management_ips = "10.0.0.0/8"

# Feature Flags
enable_ddos_protection = false  # Consider enabling for production-like environment
enable_network_watcher = true   # Essential for UAT
enable_bastion         = true   # Recommended for secure access
enable_vpn_gateway     = false  # Enable if hybrid connectivity needed
enable_nat_gateway     = true   # Recommended for controlled outbound access

# Custom Routes (empty for uat - add if needed for VPN/ExpressRoute)
custom_routes = []

#=============================================================================
# Production Environment Configuration
#=============================================================================

# Environment Settings
environment    = "prod"
location       = "eastus"
location_short = "eus"

# Project and Tagging
project_name           = "myapp"
cost_center            = "engineering"
owner_team             = "platform-team"
criticality            = "critical"
data_classification    = "confidential"

# Additional custom tags
additional_tags = {
  Terraform = "true"
  Repository = "terraform-azure-enterprise"
  ComplianceScope = "SOC2-TypeII"
}

# Networking Configuration - Larger address space for production scale
vnet_address_space = ["10.3.0.0/16"]

# DNS Servers (custom DNS recommended for production)
dns_servers = []  # Add your custom DNS servers: ["10.3.0.4", "10.3.0.5"]

# Subnet Configuration - Larger subnets for production scale
subnet_management_cidr        = "10.3.1.0/24"
subnet_appgw_cidr            = "10.3.2.0/24"
subnet_aks_system_cidr       = "10.3.10.0/24"
subnet_aks_user_cidr         = "10.3.11.0/22"   # Larger for production workloads
subnet_private_endpoints_cidr = "10.3.20.0/24"
subnet_database_cidr         = "10.3.30.0/24"
subnet_app_service_cidr      = "10.3.40.0/24"

# Security - Management Access
# CRITICAL: Only from corporate network or VPN - NEVER use "*" in production!
# Replace with your actual corporate IP ranges
allowed_management_ips = "10.0.0.0/8"  # Update with actual corporate IP ranges

# Feature Flags
enable_ddos_protection = true   # STRONGLY RECOMMENDED for production
enable_network_watcher = true   # Essential for production monitoring
enable_bastion         = true   # Required for secure production access
enable_vpn_gateway     = true   # Required for hybrid connectivity
enable_nat_gateway     = true   # Required for controlled outbound access

# Custom Routes - Example for production
# Add routes for VPN, ExpressRoute, or Azure Firewall
custom_routes = [
  # Example: Force internet traffic through Azure Firewall
  # {
  #   name                   = "internet-via-firewall"
  #   address_prefix         = "0.0.0.0/0"
  #   next_hop_type          = "VirtualAppliance"
  #   next_hop_in_ip_address = "10.3.0.4"  # Firewall IP
  # }
]

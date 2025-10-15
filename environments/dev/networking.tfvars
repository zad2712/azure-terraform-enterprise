# Development Environment - Networking Layer Configuration
# This file contains all networking-related variables for the dev environment

# =============================================================================
# Environment Configuration
# =============================================================================
environment = "dev"
location    = "East US 2"

# State storage configuration
state_storage_account_name = "" # Will be set by pipeline
state_resource_group_name  = "" # Will be set by pipeline

# =============================================================================
# Virtual Network Configuration
# =============================================================================
vnet_address_space     = ["10.1.0.0/16"]
enable_ddos_protection = false  # Cost optimization for dev
dns_servers           = []      # Use Azure default DNS

# =============================================================================
# Subnet Configuration
# =============================================================================
subnets = {
  # Web tier subnet
  web = {
    address_prefixes = ["10.1.1.0/24"]
    service_endpoints = [
      "Microsoft.Web",
      "Microsoft.Storage"
    ]
    delegation = []
  }
  
  # Application tier subnet
  app = {
    address_prefixes = ["10.1.2.0/24"]
    service_endpoints = [
      "Microsoft.Web",
      "Microsoft.Storage",
      "Microsoft.KeyVault"
    ]
    delegation = []
  }
  
  # Data tier subnet
  data = {
    address_prefixes = ["10.1.3.0/24"]
    service_endpoints = [
      "Microsoft.Sql",
      "Microsoft.Storage",
      "Microsoft.KeyVault"
    ]
    delegation = []
  }
  
  # Private endpoints subnet
  private_endpoints = {
    address_prefixes = ["10.1.4.0/24"]
    service_endpoints = []
    delegation = []
  }
  
  # Azure Kubernetes Service subnet (if using AKS)
  aks = {
    address_prefixes = ["10.1.5.0/23"]
    service_endpoints = []
    delegation = [{
      name = "Microsoft.ContainerService/managedClusters"
      service_delegation = {
        name = "Microsoft.ContainerService/managedClusters"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }]
  }
}

# =============================================================================
# Network Security Group Rules
# =============================================================================
network_security_rules = {
  web_tier = [
    {
      name                       = "Allow-HTTP"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "10.1.1.0/24"
    },
    {
      name                       = "Allow-HTTPS"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "10.1.1.0/24"
    }
  ]
  
  app_tier = [
    {
      name                       = "Allow-Web-to-App"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.1.1.0/24"
      destination_address_prefix = "10.1.2.0/24"
    }
  ]
  
  data_tier = [
    {
      name                       = "Allow-App-to-Data"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "10.1.2.0/24"
      destination_address_prefix = "10.1.3.0/24"
    }
  ]
}

# =============================================================================
# Route Table Configuration
# =============================================================================
route_tables = {
  web_rt = {
    disable_bgp_route_propagation = false
    routes = [
      {
        name           = "default-to-internet"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }
    ]
  }
}

# =============================================================================
# Network Peering Configuration
# =============================================================================
enable_network_peering = false  # Disabled for dev environment
peering_networks = {}

# =============================================================================
# Private DNS Zones
# =============================================================================
private_dns_zones = [
  "privatelink.database.windows.net",
  "privatelink.blob.core.windows.net",
  "privatelink.vaultcore.azure.net",
  "privatelink.azurewebsites.net"
]

# =============================================================================
# NAT Gateway Configuration (Optional)
# =============================================================================
enable_nat_gateway = false  # Cost optimization for dev
nat_gateway_subnets = []

# =============================================================================
# Load Balancer Configuration
# =============================================================================
enable_load_balancer = false  # Simplified setup for dev
load_balancer_type   = "Standard"

# =============================================================================
# Application Gateway Configuration
# =============================================================================
enable_application_gateway = false  # Cost optimization for dev

# =============================================================================
# Bastion Host Configuration
# =============================================================================
enable_bastion = false  # Cost optimization for dev

# =============================================================================
# Resource Tagging
# =============================================================================
tags = {
  Environment   = "dev"
  Owner        = "platform-team"
  CostCenter   = "engineering"
  Project      = "terraform-azure-enterprise"
  Workload     = "infrastructure"
  CreatedBy    = "terraform"
  CreatedDate  = "2025-01-15"
  
  # Cost management tags
  CostOptimized = "true"
  AutoShutdown  = "true"
  
  # Compliance tags
  Compliance    = "internal"
  DataClass     = "internal"
  
  # Operational tags
  Backup        = "not-required"
  Monitoring    = "basic"
  Support       = "business-hours"
}
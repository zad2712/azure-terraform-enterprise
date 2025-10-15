# Production Environment - Networking Layer Configuration
# This file contains all networking-related variables for the prod environment

# =============================================================================
# Environment Configuration
# =============================================================================
environment = "prod"
location    = "East US 2"

# State storage configuration
state_storage_account_name = "" # Will be set by pipeline
state_resource_group_name  = "" # Will be set by pipeline

# =============================================================================
# Virtual Network Configuration
# =============================================================================
vnet_address_space     = ["10.0.0.0/16"]
enable_ddos_protection = true   # Enhanced security for production
dns_servers           = []      # Use Azure default DNS

# =============================================================================
# Subnet Configuration
# =============================================================================
subnets = {
  # Web tier subnet - larger for production scaling
  web = {
    address_prefixes = ["10.0.1.0/24"]
    service_endpoints = [
      "Microsoft.Web",
      "Microsoft.Storage",
      "Microsoft.KeyVault"
    ]
    delegation = []
  }
  
  # Application tier subnet - larger address space
  app = {
    address_prefixes = ["10.0.2.0/23"]  # /23 for more IPs in production
    service_endpoints = [
      "Microsoft.Web",
      "Microsoft.Storage",
      "Microsoft.KeyVault",
      "Microsoft.Sql"
    ]
    delegation = []
  }
  
  # Data tier subnet
  data = {
    address_prefixes = ["10.0.4.0/24"]
    service_endpoints = [
      "Microsoft.Sql",
      "Microsoft.Storage",
      "Microsoft.KeyVault"
    ]
    delegation = []
  }
  
  # Private endpoints subnet
  private_endpoints = {
    address_prefixes = ["10.0.5.0/24"]
    service_endpoints = []
    delegation = []
  }
  
  # Azure Kubernetes Service subnet
  aks = {
    address_prefixes = ["10.0.6.0/22"]  # Larger for production AKS
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
  
  # Application Gateway subnet
  app_gateway = {
    address_prefixes = ["10.0.10.0/24"]
    service_endpoints = []
    delegation = []
  }
  
  # Bastion subnet (required name)
  AzureBastionSubnet = {
    address_prefixes = ["10.0.11.0/26"]  # Minimum /26 required
    service_endpoints = []
    delegation = []
  }
}

# =============================================================================
# Network Security Group Rules - Production Hardened
# =============================================================================
network_security_rules = {
  web_tier = [
    {
      name                       = "Allow-HTTPS-Only"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "10.0.1.0/24"
    },
    {
      name                       = "Deny-HTTP"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
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
      source_address_prefix      = "10.0.1.0/24"
      destination_address_prefix = "10.0.2.0/23"
    },
    {
      name                       = "Allow-AppGateway-to-App"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.0.10.0/24"
      destination_address_prefix = "10.0.2.0/23"
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
      source_address_prefix      = "10.0.2.0/23"
      destination_address_prefix = "10.0.4.0/24"
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
        name           = "default-to-firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.100.4"  # Azure Firewall IP
      }
    ]
  }
  
  app_rt = {
    disable_bgp_route_propagation = false
    routes = [
      {
        name           = "default-to-firewall"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.100.4"
      }
    ]
  }
}

# =============================================================================
# Network Peering Configuration
# =============================================================================
enable_network_peering = true
peering_networks = {
  hub_connection = {
    vnet_name                = "vnet-hub-prod"
    resource_group_name      = "rg-hub-prod"
    allow_virtual_network_access = true
    allow_forwarded_traffic  = true
    allow_gateway_transit    = false
    use_remote_gateways     = true
  }
}

# =============================================================================
# Private DNS Zones
# =============================================================================
private_dns_zones = [
  "privatelink.database.windows.net",
  "privatelink.blob.core.windows.net",
  "privatelink.file.core.windows.net",
  "privatelink.vaultcore.azure.net",
  "privatelink.azurewebsites.net",
  "privatelink.redis.cache.windows.net",
  "privatelink.postgres.database.azure.com",
  "privatelink.mysql.database.azure.com"
]

# =============================================================================
# NAT Gateway Configuration
# =============================================================================
enable_nat_gateway = true
nat_gateway_subnets = ["app", "data"]

# =============================================================================
# Load Balancer Configuration
# =============================================================================
enable_load_balancer = true
load_balancer_type   = "Standard"

# =============================================================================
# Application Gateway Configuration
# =============================================================================
enable_application_gateway = true

# =============================================================================
# Bastion Host Configuration
# =============================================================================
enable_bastion = true

# =============================================================================
# Azure Firewall Configuration
# =============================================================================
enable_azure_firewall = true

# =============================================================================
# Resource Tagging - Production
# =============================================================================
tags = {
  Environment   = "prod"
  Owner        = "platform-team"
  CostCenter   = "production"
  Project      = "terraform-azure-enterprise"
  Workload     = "infrastructure"
  CreatedBy    = "terraform"
  CreatedDate  = "2025-01-15"
  
  # Cost management tags
  CostOptimized = "false"
  AutoShutdown  = "false"
  
  # Compliance tags
  Compliance    = "sox-compliant"
  DataClass     = "confidential"
  
  # Operational tags
  Backup        = "required"
  Monitoring    = "enhanced"
  Support       = "24x7"
  
  # Security tags
  SecurityLevel = "high"
  Encryption    = "required"
  
  # Business continuity
  DisasterRecovery = "required"
  RTO             = "1-hour"
  RPO             = "15-minutes"
}
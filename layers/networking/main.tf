/**
 * Networking Layer - Root Module
 * 
 * This layer calls modules from /modules to create networking infrastructure.
 * NO resources are created directly here - only module calls.
 */

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # Backend configuration provided via backend.conf file
    # terraform init -backend-config=environments/<env>/backend.conf
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

#=============================================================================
# Resource Group Module
#=============================================================================

module "networking_rg" {
  source = "../../modules/resource-group"

  name       = "rg-${local.naming_prefix}-network-${var.location}"
  location   = var.location
  tags       = local.common_tags
  lock_level = var.environment == "prod" ? "CanNotDelete" : null
}

#=============================================================================
# Virtual Network Module
#=============================================================================

module "vnet" {
  source = "../../modules/networking/vnet"

  name                = "vnet-${local.naming_prefix}-${local.location_short}"
  location            = var.location
  resource_group_name = module.networking_rg.name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers

  log_analytics_workspace_id = null  # Add when monitoring layer deployed

  tags = local.common_tags

  depends_on = [module.networking_rg]
}

#=============================================================================
# Subnet Modules
#=============================================================================

module "subnet_management" {
  source = "../../modules/networking/subnet"

  name                 = "snet-${local.naming_prefix}-management"
  resource_group_name  = module.networking_rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [var.subnet_management_cidr]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

module "subnet_appgw" {
  source = "../../modules/networking/subnet"

  name                 = "snet-${local.naming_prefix}-appgw"
  resource_group_name  = module.networking_rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [var.subnet_appgw_cidr]
  service_endpoints    = []
}

module "subnet_aks_system" {
  source = "../../modules/networking/subnet"

  name                 = "snet-${local.naming_prefix}-aks-system"
  resource_group_name  = module.networking_rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [var.subnet_aks_system_cidr]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
}

module "subnet_aks_user" {
  source = "../../modules/networking/subnet"

  name                 = "snet-${local.naming_prefix}-aks-user"
  resource_group_name  = module.networking_rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [var.subnet_aks_user_cidr]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
}

module "subnet_private_endpoints" {
  source = "../../modules/networking/subnet"

  name                                      = "snet-${local.naming_prefix}-privateendpoints"
  resource_group_name                       = module.networking_rg.name
  virtual_network_name                      = module.vnet.name
  address_prefixes                          = [var.subnet_private_endpoints_cidr]
  service_endpoints                         = []
  private_endpoint_network_policies_enabled = false
}

module "subnet_database" {
  source = "../../modules/networking/subnet"

  name                 = "snet-${local.naming_prefix}-database"
  resource_group_name  = module.networking_rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [var.subnet_database_cidr]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]

  delegation_name    = "delegation"
  service_delegation = "Microsoft.DBforPostgreSQL/flexibleServers"
  delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
}

module "subnet_app_service" {
  source = "../../modules/networking/subnet"

  name                 = "snet-${local.naming_prefix}-appservice"
  resource_group_name  = module.networking_rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [var.subnet_app_service_cidr]
  service_endpoints    = []

  delegation_name    = "delegation"
  service_delegation = "Microsoft.Web/serverFarms"
  delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
}

#=============================================================================
# Network Security Group Modules
#=============================================================================

module "nsg_management" {
  source = "../../modules/networking/nsg"

  name                = "nsg-${local.naming_prefix}-management"
  location            = var.location
  resource_group_name = module.networking_rg.name

  security_rules = [
    {
      name                       = "AllowSSHInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.allowed_management_ips
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowRDPInbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = var.allowed_management_ips
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = local.common_tags
}

module "nsg_aks" {
  source = "../../modules/networking/nsg"

  name                = "nsg-${local.naming_prefix}-aks"
  location            = var.location
  resource_group_name = module.networking_rg.name

  security_rules = [
    {
      name                       = "AllowAKSControlPlane"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureCloud"
      destination_address_prefix = "*"
    }
  ]

  tags = local.common_tags
}

module "nsg_database" {
  source = "../../modules/networking/nsg"

  name                = "nsg-${local.naming_prefix}-database"
  location            = var.location
  resource_group_name = module.networking_rg.name

  security_rules = [
    {
      name                       = "AllowPostgreSQLFromVNet"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432"
      source_address_prefixes    = var.vnet_address_space
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowMySQLFromVNet"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefixes    = var.vnet_address_space
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowSQLServerFromVNet"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefixes    = var.vnet_address_space
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = local.common_tags
}

#=============================================================================
# NSG Association Modules
#=============================================================================

module "nsg_association_management" {
  source = "../../modules/networking/nsg-association"

  subnet_id                 = module.subnet_management.id
  network_security_group_id = module.nsg_management.id
}

module "nsg_association_aks_system" {
  source = "../../modules/networking/nsg-association"

  subnet_id                 = module.subnet_aks_system.id
  network_security_group_id = module.nsg_aks.id
}

module "nsg_association_aks_user" {
  source = "../../modules/networking/nsg-association"

  subnet_id                 = module.subnet_aks_user.id
  network_security_group_id = module.nsg_aks.id
}

module "nsg_association_database" {
  source = "../../modules/networking/nsg-association"

  subnet_id                 = module.subnet_database.id
  network_security_group_id = module.nsg_database.id
}

#=============================================================================
# Route Table Module
#=============================================================================

module "route_table" {
  source = "../../modules/networking/route-table"

  name                = "rt-${local.naming_prefix}-main"
  location            = var.location
  resource_group_name = module.networking_rg.name

  routes = []  # Add custom routes as needed

  tags = local.common_tags
}

#=============================================================================
# Route Table Association Modules
#=============================================================================

module "rt_association_aks_system" {
  source = "../../modules/networking/route-table-association"

  subnet_id      = module.subnet_aks_system.id
  route_table_id = module.route_table.id
}

module "rt_association_aks_user" {
  source = "../../modules/networking/route-table-association"

  subnet_id      = module.subnet_aks_user.id
  route_table_id = module.route_table.id
}

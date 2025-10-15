#=============================================================================
# Resource Group Outputs
#=============================================================================

output "resource_group_id" {
  description = "ID of the networking resource group"
  value       = module.networking_rg.id
}

output "resource_group_name" {
  description = "Name of the networking resource group"
  value       = module.networking_rg.name
}

output "resource_group_location" {
  description = "Location of the networking resource group"
  value       = module.networking_rg.location
}

#=============================================================================
# Virtual Network Outputs
#=============================================================================

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = module.vnet.address_space
}

#=============================================================================
# Subnet Outputs
#=============================================================================

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    management        = module.subnet_management.id
    appgw            = module.subnet_appgw.id
    aks_system       = module.subnet_aks_system.id
    aks_user         = module.subnet_aks_user.id
    private_endpoints = module.subnet_private_endpoints.id
    database         = module.subnet_database.id
    app_service      = module.subnet_app_service.id
  }
}

output "subnet_management_id" {
  description = "ID of the management subnet"
  value       = module.subnet_management.id
}

output "subnet_management_name" {
  description = "Name of the management subnet"
  value       = module.subnet_management.name
}

output "subnet_appgw_id" {
  description = "ID of the Application Gateway subnet"
  value       = module.subnet_appgw.id
}

output "subnet_appgw_name" {
  description = "Name of the Application Gateway subnet"
  value       = module.subnet_appgw.name
}

output "subnet_aks_system_id" {
  description = "ID of the AKS system node pool subnet"
  value       = module.subnet_aks_system.id
}

output "subnet_aks_system_name" {
  description = "Name of the AKS system node pool subnet"
  value       = module.subnet_aks_system.name
}

output "subnet_aks_user_id" {
  description = "ID of the AKS user node pool subnet"
  value       = module.subnet_aks_user.id
}

output "subnet_aks_user_name" {
  description = "Name of the AKS user node pool subnet"
  value       = module.subnet_aks_user.name
}

output "subnet_private_endpoints_id" {
  description = "ID of the private endpoints subnet"
  value       = module.subnet_private_endpoints.id
}

output "subnet_private_endpoints_name" {
  description = "Name of the private endpoints subnet"
  value       = module.subnet_private_endpoints.name
}

output "subnet_database_id" {
  description = "ID of the database subnet"
  value       = module.subnet_database.id
}

output "subnet_database_name" {
  description = "Name of the database subnet"
  value       = module.subnet_database.name
}

output "subnet_app_service_id" {
  description = "ID of the App Service subnet"
  value       = module.subnet_app_service.id
}

output "subnet_app_service_name" {
  description = "Name of the App Service subnet"
  value       = module.subnet_app_service.name
}

#=============================================================================
# Network Security Group Outputs
#=============================================================================

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value = {
    management = module.nsg_management.id
    aks        = module.nsg_aks.id
    database   = module.nsg_database.id
  }
}

output "nsg_management_id" {
  description = "ID of the management NSG"
  value       = module.nsg_management.id
}

output "nsg_aks_id" {
  description = "ID of the AKS NSG"
  value       = module.nsg_aks.id
}

output "nsg_database_id" {
  description = "ID of the database NSG"
  value       = module.nsg_database.id
}

#=============================================================================
# Route Table Outputs
#=============================================================================

output "route_table_id" {
  description = "ID of the main route table"
  value       = module.route_table.id
}

output "route_table_name" {
  description = "Name of the main route table"
  value       = module.route_table.name
}

#=============================================================================
# Output for Cross-Layer Reference
#=============================================================================

output "network_config" {
  description = "Complete network configuration for cross-layer reference"
  value = {
    vnet_id           = module.vnet.id
    vnet_name         = module.vnet.name
    address_space     = module.vnet.address_space
    resource_group    = module.networking_rg.name
    location          = var.location
    subnets           = {
      management        = module.subnet_management.id
      appgw            = module.subnet_appgw.id
      aks_system       = module.subnet_aks_system.id
      aks_user         = module.subnet_aks_user.id
      private_endpoints = module.subnet_private_endpoints.id
      database         = module.subnet_database.id
      app_service      = module.subnet_app_service.id
    }
    nsgs = {
      management = module.nsg_management.id
      aks        = module.nsg_aks.id
      database   = module.nsg_database.id
    }
  }
  sensitive = false
}

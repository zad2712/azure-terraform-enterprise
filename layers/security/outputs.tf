# Resource Group Outputs
output "resource_group_id" {
  description = "Security resource group ID"
  value       = module.security_rg.id
}

output "resource_group_name" {
  description = "Security resource group name"
  value       = module.security_rg.name
}

# Key Vault Outputs
output "key_vault_id" {
  description = "Key Vault ID"
  value       = module.key_vault.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.vault_uri
}

# Managed Identity Outputs
output "aks_workload_identity_id" {
  description = "AKS workload managed identity ID"
  value       = var.enable_aks_workload_identity ? azurerm_user_assigned_identity.aks_workload[0].id : null
}

output "aks_workload_identity_client_id" {
  description = "AKS workload managed identity client ID"
  value       = var.enable_aks_workload_identity ? azurerm_user_assigned_identity.aks_workload[0].client_id : null
}

output "app_service_identity_id" {
  description = "App Service managed identity ID"
  value       = var.enable_app_service_identity ? azurerm_user_assigned_identity.app_service[0].id : null
}

output "app_service_identity_client_id" {
  description = "App Service managed identity client ID"
  value       = var.enable_app_service_identity ? azurerm_user_assigned_identity.app_service[0].client_id : null
}

# Cross-layer reference
output "security_config" {
  description = "Security configuration for cross-layer reference"
  value = {
    resource_group = module.security_rg.name
    key_vault_id   = module.key_vault.id
    key_vault_name = module.key_vault.name
    key_vault_uri  = module.key_vault.vault_uri
    identities = {
      aks_workload  = var.enable_aks_workload_identity ? azurerm_user_assigned_identity.aks_workload[0].id : null
      app_service   = var.enable_app_service_identity ? azurerm_user_assigned_identity.app_service[0].id : null
    }
  }
}

#=============================================================================
# Resource Group Outputs
#=============================================================================

output "resource_group_id" {
  description = "ID of the compute resource group"
  value       = module.compute_rg.id
}

output "resource_group_name" {
  description = "Name of the compute resource group"
  value       = module.compute_rg.name
}

#=============================================================================
# AKS Outputs
#=============================================================================

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = var.enable_aks ? module.aks[0].id : null
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = var.enable_aks ? module.aks[0].name : null
}

output "aks_kube_config" {
  description = "Kubernetes configuration for AKS cluster"
  value       = var.enable_aks ? module.aks[0].kube_config : null
  sensitive   = true
}

output "aks_host" {
  description = "AKS cluster API server endpoint"
  value       = var.enable_aks ? module.aks[0].host : null
  sensitive   = true
}

output "aks_identity_principal_id" {
  description = "Principal ID of AKS managed identity"
  value       = var.enable_aks ? module.aks[0].identity_principal_id : null
}

output "aks_kubelet_identity" {
  description = "Kubelet managed identity"
  value       = var.enable_aks ? module.aks[0].kubelet_identity : null
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  value       = var.enable_aks ? module.aks[0].oidc_issuer_url : null
}

#=============================================================================
# Output for Cross-Layer Reference
#=============================================================================

output "compute_config" {
  description = "Complete compute configuration for cross-layer reference"
  value = {
    resource_group = module.compute_rg.name
    location       = var.location
    aks = var.enable_aks ? {
      cluster_id           = module.aks[0].id
      cluster_name         = module.aks[0].name
      identity_principal_id = module.aks[0].identity_principal_id
      oidc_issuer_url      = module.aks[0].oidc_issuer_url
    } : null
  }
  sensitive = false
}

#=============================================================================
# Web App Outputs
#=============================================================================

output "web_app_id" {
  description = "ID of the Web App"
  value       = var.enable_web_app ? module.web_app[0].id : null
}

output "web_app_name" {
  description = "Name of the Web App"
  value       = var.enable_web_app ? module.web_app[0].name : null
}

output "web_app_default_hostname" {
  description = "Default hostname of the Web App"
  value       = var.enable_web_app ? module.web_app[0].default_hostname : null
}

output "web_app_outbound_ip_addresses" {
  description = "Outbound IP addresses of the Web App"
  value       = var.enable_web_app ? module.web_app[0].outbound_ip_addresses : null
}

output "web_app_identity_principal_id" {
  description = "Principal ID of the Web App managed identity"
  value       = var.enable_web_app ? module.web_app[0].identity_principal_id : null
}

output "web_app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = var.enable_web_app ? module.web_app[0].service_plan_id : null
}

/**
 * Azure Kubernetes Service (AKS) Module
 * 
 * Creates a production-ready AKS cluster with:
 * - Multiple node pools with auto-scaling
 * - Azure CNI networking
 * - Azure AD integration
 * - Azure Monitor integration
 * - Private cluster option
 * - Azure Policy integration
 * - Workload identity support
 */

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.dns_prefix
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = var.sku_tier
  private_cluster_enabled   = var.private_cluster_enabled
  automatic_channel_upgrade = var.automatic_channel_upgrade
  node_resource_group       = "${var.resource_group_name}-aks-nodes"

  default_node_pool {
    name                   = var.default_node_pool.name
    vm_size                = var.default_node_pool.vm_size
    node_count             = var.default_node_pool.node_count
    enable_auto_scaling    = var.default_node_pool.enable_auto_scaling
    min_count              = var.default_node_pool.min_count
    max_count              = var.default_node_pool.max_count
    max_pods               = var.default_node_pool.max_pods
    os_disk_size_gb        = var.default_node_pool.os_disk_size_gb
    os_disk_type           = var.default_node_pool.os_disk_type
    vnet_subnet_id         = var.default_node_pool.subnet_id
    zones                  = var.default_node_pool.availability_zones
    enable_host_encryption = var.enable_host_encryption
    enable_node_public_ip  = false

    upgrade_settings {
      max_surge = var.default_node_pool.max_surge
    }

    tags = merge(var.tags, {
      NodePool = var.default_node_pool.name
    })
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    load_balancer_sku  = "standard"
    outbound_type      = var.outbound_type
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  microsoft_defender {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  azure_policy_enabled = var.azure_policy_enabled

  key_vault_secrets_provider {
    secret_rotation_enabled = var.enable_secret_rotation
  }

  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled

  maintenance_window {
    allowed {
      day   = var.maintenance_window.day
      hours = var.maintenance_window.hours
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].node_count
    ]
  }
}

# Additional Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = var.additional_node_pools

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  vnet_subnet_id        = each.value.subnet_id
  zones                 = each.value.availability_zones
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  mode                  = each.value.mode
  priority              = each.value.priority
  spot_max_price        = each.value.spot_max_price

  upgrade_settings {
    max_surge = each.value.max_surge
  }

  tags = merge(var.tags, {
    NodePool = each.value.name
  })
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "${var.cluster_name}-diagnostics"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = [
      "kube-apiserver",
      "kube-controller-manager",
      "kube-scheduler",
      "kube-audit",
      "kube-audit-admin",
      "guard",
      "cluster-autoscaler"
    ]
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

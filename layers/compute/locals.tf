#=============================================================================
# Local Values
#=============================================================================

locals {
  # Naming prefix
  naming_prefix = "${var.project_name}-${var.environment}"

  # Common tags
  common_tags = merge(
    {
      Environment        = var.environment
      ManagedBy          = "terraform"
      Project            = var.project_name
      CostCenter         = var.cost_center
      Owner              = var.owner_team
      Criticality        = var.criticality
      DataClassification = var.data_classification
      Layer              = "compute"
      DeploymentDate     = formatdate("YYYY-MM-DD", timestamp())
    },
    var.additional_tags
  )

  # Environment-specific AKS configuration
  aks_config = {
    dev = {
      sku_tier                     = "Free"
      private_cluster_enabled      = false
      system_node_pool_vm_size     = "Standard_D2s_v3"
      system_node_pool_count       = 1
      system_node_pool_min_count   = 1
      system_node_pool_max_count   = 3
      enable_auto_scaling          = true
    }
    qa = {
      sku_tier                     = "Standard"
      private_cluster_enabled      = false
      system_node_pool_vm_size     = "Standard_D2s_v3"
      system_node_pool_count       = 2
      system_node_pool_min_count   = 2
      system_node_pool_max_count   = 5
      enable_auto_scaling          = true
    }
    uat = {
      sku_tier                     = "Standard"
      private_cluster_enabled      = true
      system_node_pool_vm_size     = "Standard_D4s_v3"
      system_node_pool_count       = 3
      system_node_pool_min_count   = 3
      system_node_pool_max_count   = 7
      enable_auto_scaling          = true
    }
    prod = {
      sku_tier                     = "Standard"
      private_cluster_enabled      = true
      system_node_pool_vm_size     = "Standard_D4s_v3"
      system_node_pool_count       = 3
      system_node_pool_min_count   = 3
      system_node_pool_max_count   = 10
      enable_auto_scaling          = true
    }
  }[var.environment]

  # Environment-specific App Service configuration
  app_service_config = {
    dev = {
      sku_tier = "Basic"
      sku_size = "B1"
    }
    qa = {
      sku_tier = "Standard"
      sku_size = "S1"
    }
    uat = {
      sku_tier = "Standard"
      sku_size = "S2"
    }
    prod = {
      sku_tier = "Premium"
      sku_size = "P1v3"
    }
  }[var.environment]

  # Environment-specific VMSS configuration
  vmss_config = {
    dev = {
      sku            = "Standard_B2s"
      instance_count = 1
      min_count      = 1
      max_count      = 2
    }
    qa = {
      sku            = "Standard_D2s_v3"
      instance_count = 2
      min_count      = 2
      max_count      = 5
    }
    uat = {
      sku            = "Standard_D2s_v3"
      instance_count = 2
      min_count      = 2
      max_count      = 10
    }
    prod = {
      sku            = "Standard_D4s_v3"
      instance_count = 3
      min_count      = 3
      max_count      = 20
    }
  }[var.environment]

  # Environment-specific feature flags
  feature_flags = {
    dev = {
      enable_monitoring           = true
      enable_backup               = false
      enable_auto_shutdown        = true
      enable_diagnostic_settings  = true
      enable_private_endpoints    = false
    }
    qa = {
      enable_monitoring           = true
      enable_backup               = true
      enable_auto_shutdown        = false
      enable_diagnostic_settings  = true
      enable_private_endpoints    = true
    }
    uat = {
      enable_monitoring           = true
      enable_backup               = true
      enable_auto_shutdown        = false
      enable_diagnostic_settings  = true
      enable_private_endpoints    = true
    }
    prod = {
      enable_monitoring           = true
      enable_backup               = true
      enable_auto_shutdown        = false
      enable_diagnostic_settings  = true
      enable_private_endpoints    = true
    }
  }[var.environment]
}
  # Environment-specific App Service configuration
  app_service_config = {
    dev = {
      sku_name                      = "B1"
      zone_balancing_enabled        = false
      worker_count                  = 1
      always_on                     = false
      public_network_access_enabled = true
      http_logs_retention_days      = 7
      enable_deployment_slot        = false
    }
    qa = {
      sku_name                      = "S1"
      zone_balancing_enabled        = false
      worker_count                  = 2
      always_on                     = true
      public_network_access_enabled = true
      http_logs_retention_days      = 14
      enable_deployment_slot        = true
    }
    uat = {
      sku_name                      = "S2"
      zone_balancing_enabled        = true
      worker_count                  = 2
      always_on                     = true
      public_network_access_enabled = false
      http_logs_retention_days      = 30
      enable_deployment_slot        = true
    }
    prod = {
      sku_name                      = "P1v3"
      zone_balancing_enabled        = true
      worker_count                  = 3
      always_on                     = true
      public_network_access_enabled = false
      http_logs_retention_days      = 90
      enable_deployment_slot        = true
    }
  }[var.environment]

  # Environment-specific Web App configuration
  web_app_config = {
    dev = {
      zone_redundant      = false
      web_app_private_only = false
      web_app_vnet_route_all = false
    }
    qa = {
      zone_redundant      = false
      web_app_private_only = false
      web_app_vnet_route_all = true
    }
    uat = {
      zone_redundant      = true
      web_app_private_only = true
      web_app_vnet_route_all = true
    }
    prod = {
      zone_redundant      = true
      web_app_private_only = true
      web_app_vnet_route_all = true
    }
  }[var.environment]

  # Combined compute configuration for easy reference
  compute_config = merge(
    local.aks_config,
    local.app_service_config,
    local.vmss_config,
    local.web_app_config,
    local.feature_flags
  )

  # Location short codes
  location_codes = {
    eastus  = "eus"
    eastus2 = "eus2"
    westus  = "wus"
    westus2 = "wus2"
  }

  location_short = lookup(local.location_codes, var.location, substr(var.location, 0, 3))
}

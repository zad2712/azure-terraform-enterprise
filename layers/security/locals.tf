locals {
  # Naming
  naming_prefix = "${var.project_name}-${var.environment}"
  
  location_codes = {
    eastus  = "eus"
    eastus2 = "eus2"
    westus  = "wus"
    westus2 = "wus2"
  }
  
  location_short = lookup(local.location_codes, var.location, substr(var.location, 0, 3))

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
      Layer              = "security"
    },
    var.additional_tags
  )

  # Environment-specific security configuration
  security_config = {
    dev = {
      kv_sku                      = "standard"
      kv_soft_delete_retention    = 7
      kv_purge_protection         = false
      kv_private_endpoint_only    = false
      kv_default_action           = "Allow"
      enable_private_endpoints    = false
    }
    qa = {
      kv_sku                      = "standard"
      kv_soft_delete_retention    = 14
      kv_purge_protection         = false
      kv_private_endpoint_only    = false
      kv_default_action           = "Deny"
      enable_private_endpoints    = true
    }
    uat = {
      kv_sku                      = "premium"
      kv_soft_delete_retention    = 30
      kv_purge_protection         = true
      kv_private_endpoint_only    = true
      kv_default_action           = "Deny"
      enable_private_endpoints    = true
    }
    prod = {
      kv_sku                      = "premium"
      kv_soft_delete_retention    = 90
      kv_purge_protection         = true
      kv_private_endpoint_only    = true
      kv_default_action           = "Deny"
      enable_private_endpoints    = true
    }
  }[var.environment]
}

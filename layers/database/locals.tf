locals {
  naming_prefix = "${var.project_name}-${var.environment}"
  
  location_codes = {
    eastus  = "eus"
    eastus2 = "eus2"
    westus  = "wus"
    westus2 = "wus2"
  }
  
  location_short = lookup(local.location_codes, var.location, substr(var.location, 0, 3))

  common_tags = merge(
    {
      Environment        = var.environment
      ManagedBy          = "terraform"
      Project            = var.project_name
      CostCenter         = var.cost_center
      Owner              = var.owner_team
      Criticality        = var.criticality
      DataClassification = var.data_classification
      Layer              = "database"
    },
    var.additional_tags
  )

  # Environment-specific database configuration
  database_config = {
    dev = {
      sql_sku                  = "Basic"
      sql_max_size_gb          = 2
      sql_zone_redundant       = false
      backup_redundancy        = "Local"
      short_term_retention     = 7
      redis_sku                = "Basic"
      redis_family             = "C"
      redis_capacity           = 0
      redis_maxmemory_reserved = 2
      redis_maxmemory_delta    = 2
      enable_private_endpoints = false
    }
    qa = {
      sql_sku                  = "S1"
      sql_max_size_gb          = 10
      sql_zone_redundant       = false
      backup_redundancy        = "Geo"
      short_term_retention     = 14
      redis_sku                = "Standard"
      redis_family             = "C"
      redis_capacity           = 1
      redis_maxmemory_reserved = 50
      redis_maxmemory_delta    = 50
      enable_private_endpoints = true
    }
    uat = {
      sql_sku                  = "S2"
      sql_max_size_gb          = 50
      sql_zone_redundant       = true
      backup_redundancy        = "Geo"
      short_term_retention     = 21
      redis_sku                = "Standard"
      redis_family             = "C"
      redis_capacity           = 2
      redis_maxmemory_reserved = 125
      redis_maxmemory_delta    = 125
      enable_private_endpoints = true
    }
    prod = {
      sql_sku                  = "P2"
      sql_max_size_gb          = 250
      sql_zone_redundant       = true
      backup_redundancy        = "GeoZone"
      short_term_retention     = 35
      redis_sku                = "Premium"
      redis_family             = "P"
      redis_capacity           = 1
      redis_maxmemory_reserved = 615
      redis_maxmemory_delta    = 615
      enable_private_endpoints = true
    }
  }[var.environment]
}

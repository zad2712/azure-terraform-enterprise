#=============================================================================
# Local Values
#=============================================================================

locals {
  # Naming prefix used across all resources
  naming_prefix = "${var.project_name}-${var.environment}"

  # Common tags applied to all resources
  common_tags = merge(
    {
      Environment        = var.environment
      ManagedBy          = "terraform"
      Project            = var.project_name
      CostCenter         = var.cost_center
      Owner              = var.owner_team
      Criticality        = var.criticality
      DataClassification = var.data_classification
      Layer              = "networking"
      DeploymentDate     = formatdate("YYYY-MM-DD", timestamp())
      TerraformWorkspace = terraform.workspace
    },
    var.additional_tags
  )

  # Location short codes for resource naming
  location_codes = {
    eastus      = "eus"
    eastus2     = "eus2"
    westus      = "wus"
    westus2     = "wus2"
    centralus   = "cus"
    northcentralus = "ncus"
    southcentralus = "scus"
    westcentralus  = "wcus"
    canadacentral  = "cac"
    canadaeast     = "cae"
    brazilsouth    = "brs"
    northeurope    = "neu"
    westeurope     = "weu"
    uksouth        = "uks"
    ukwest         = "ukw"
    francecentral  = "frc"
    francesouth    = "frs"
    germanywestcentral = "gwc"
    norwayeast     = "noe"
    switzerlandnorth = "szn"
    swedencentral  = "swc"
    eastasia       = "eas"
    southeastasia  = "seas"
    japaneast      = "jpe"
    japanwest      = "jpw"
    australiaeast  = "aue"
    australiasoutheast = "ause"
    centralindia   = "inc"
    southindia     = "ins"
    westindia      = "inw"
  }

  # Get short location code
  location_short = lookup(local.location_codes, var.location, substr(var.location, 0, 3))

  # Environment-specific configuration
  env_config = {
    dev = {
      enable_deletion_protection = false
      nsg_log_retention_days     = 7
      flow_log_retention_days    = 7
      enable_traffic_analytics   = false
      route_table_disable_bgp    = true
    }
    qa = {
      enable_deletion_protection = false
      nsg_log_retention_days     = 14
      flow_log_retention_days    = 14
      enable_traffic_analytics   = true
      route_table_disable_bgp    = true
    }
    uat = {
      enable_deletion_protection = true
      nsg_log_retention_days     = 30
      flow_log_retention_days    = 30
      enable_traffic_analytics   = true
      route_table_disable_bgp    = false
    }
    prod = {
      enable_deletion_protection = true
      nsg_log_retention_days     = 90
      flow_log_retention_days    = 90
      enable_traffic_analytics   = true
      route_table_disable_bgp    = false
    }
  }

  # Current environment configuration
  current_env_config = local.env_config[var.environment]

  # Subnet configuration map for easy reference
  subnets = {
    management = {
      name             = "snet-${local.naming_prefix}-management"
      address_prefix   = var.subnet_management_cidr
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation       = null
    }
    appgw = {
      name             = "snet-${local.naming_prefix}-appgw"
      address_prefix   = var.subnet_appgw_cidr
      service_endpoints = []
      delegation       = null
    }
    aks_system = {
      name             = "snet-${local.naming_prefix}-aks-system"
      address_prefix   = var.subnet_aks_system_cidr
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
      delegation       = null
    }
    aks_user = {
      name             = "snet-${local.naming_prefix}-aks-user"
      address_prefix   = var.subnet_aks_user_cidr
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
      delegation       = null
    }
    private_endpoints = {
      name             = "snet-${local.naming_prefix}-privateendpoints"
      address_prefix   = var.subnet_private_endpoints_cidr
      service_endpoints = []
      delegation       = null
    }
    database = {
      name             = "snet-${local.naming_prefix}-database"
      address_prefix   = var.subnet_database_cidr
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
      delegation       = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
    app_service = {
      name             = "snet-${local.naming_prefix}-appservice"
      address_prefix   = var.subnet_app_service_cidr
      service_endpoints = []
      delegation       = "Microsoft.Web/serverFarms"
    }
  }

  # NSG rules - common rules that can be referenced
  common_nsg_rules = {
    deny_all_inbound = {
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
  }

  # Resource naming standards
  resource_names = {
    vnet              = "vnet-${local.naming_prefix}-${local.location_short}"
    route_table       = "rt-${local.naming_prefix}-${local.location_short}"
    nat_gateway       = "natgw-${local.naming_prefix}-${local.location_short}"
    bastion           = "bas-${local.naming_prefix}-${local.location_short}"
    vpn_gateway       = "vpngw-${local.naming_prefix}-${local.location_short}"
    network_watcher   = "nw-${local.naming_prefix}-${local.location_short}"
    ddos_plan         = "ddos-${local.naming_prefix}-${local.location_short}"
  }
}

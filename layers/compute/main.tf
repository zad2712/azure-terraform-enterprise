/**
 * Compute Layer - Root Module
 * 
 * This layer manages compute resources by calling modules from /modules.
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
    virtual_machine_scale_set {
      roll_instances_when_required = true
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Remote state data - networking layer
data "terraform_remote_state" "networking" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstate"
    key                  = "networking-${var.environment}.tfstate"
    resource_group_name  = var.state_resource_group_name
  }
}

# Remote state data - security layer
data "terraform_remote_state" "security" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstate"
    key                  = "security-${var.environment}.tfstate"
    resource_group_name  = var.state_resource_group_name
  }
}

#=============================================================================
# Resource Group Module
#=============================================================================

module "compute_rg" {
  source = "../../modules/resource-group"

  name       = "rg-${local.naming_prefix}-compute-${var.location}"
  location   = var.location
  tags       = local.common_tags
  lock_level = var.environment == "prod" ? "CanNotDelete" : null
}

#=============================================================================
# AKS Cluster Module
#=============================================================================

module "aks" {
  count  = var.enable_aks ? 1 : 0
  source = "../../modules/compute/aks"

  cluster_name        = "aks-${local.naming_prefix}"
  location            = var.location
  resource_group_name = module.compute_rg.name
  dns_prefix          = "${local.naming_prefix}-aks"
  kubernetes_version  = var.aks_kubernetes_version
  sku_tier            = local.aks_config.sku_tier

  # Default node pool configuration
  default_node_pool = {
    name                = "system"
    vm_size             = local.aks_config.system_node_pool_vm_size
    node_count          = local.aks_config.system_node_pool_count
    enable_auto_scaling = true
    min_count           = local.aks_config.system_node_pool_min_count
    max_count           = local.aks_config.system_node_pool_max_count
    max_pods            = 110
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    subnet_id           = data.terraform_remote_state.networking.outputs.subnet_aks_system_id
    availability_zones  = var.availability_zones
    max_surge           = "33%"
  }

  # Additional node pools
  additional_node_pools = var.aks_additional_node_pools

  # Network configuration
  network_plugin = "azure"
  network_policy = "azure"
  dns_service_ip = var.aks_dns_service_ip
  service_cidr   = var.aks_service_cidr
  outbound_type  = "loadBalancer"

  # Azure AD integration
  admin_group_object_ids = var.aks_admin_group_object_ids
  azure_rbac_enabled     = true

  # Monitoring
  log_analytics_workspace_id = try(data.terraform_remote_state.security.outputs.log_analytics_workspace_id, null)

  # Security features
  private_cluster_enabled   = local.aks_config.private_cluster_enabled
  azure_policy_enabled      = true
  enable_host_encryption    = true
  enable_secret_rotation    = true
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  # Maintenance window
  maintenance_window = var.aks_maintenance_window

  identity_type = "SystemAssigned"
  identity_ids  = []

  tags = local.common_tags

  depends_on = [module.compute_rg]
}

#=============================================================================
# App Service Module
#=============================================================================

module "app_service" {
  count  = var.enable_app_service ? 1 : 0
  source = "../../modules/compute/app-service"

  app_service_plan_name = "asp-${local.naming_prefix}"
  app_service_name      = "app-${local.naming_prefix}"
  location              = var.location
  resource_group_name   = module.compute_rg.name

  # App Service Plan configuration
  os_type                = var.app_service_os_type
  sku_name               = local.app_service_config.sku_name
  zone_balancing_enabled = local.app_service_config.zone_balancing_enabled
  worker_count           = local.app_service_config.worker_count

  # App Service configuration
  always_on                     = local.app_service_config.always_on
  public_network_access_enabled = local.app_service_config.public_network_access_enabled
  vnet_integration_subnet_id    = local.feature_flags.enable_vnet_integration ? data.terraform_remote_state.networking.outputs.subnet_app_service_id : null

  # Health check
  health_check_path          = var.app_service_health_check_path
  health_check_eviction_time = 2

  # Application stack
  application_stack = var.app_service_application_stack

  # IP restrictions
  ip_restrictions = var.app_service_ip_restrictions

  # Application settings
  app_settings = var.app_service_app_settings

  # Connection strings
  connection_strings = var.app_service_connection_strings

  # Managed identity
  identity_type = local.feature_flags.use_managed_identity ? "SystemAssigned" : "SystemAssigned"
  identity_ids  = []

  # Logging
  http_logs_retention_days = local.app_service_config.http_logs_retention_days

  # Application Insights
  application_insights_key = null  # Add when monitoring layer is deployed

  # Deployment slot
  enable_deployment_slot = local.app_service_config.enable_deployment_slot

  # Private endpoint
  private_endpoint_subnet_id = local.feature_flags.enable_private_endpoints ? data.terraform_remote_state.networking.outputs.subnet_private_endpoints_id : null
  private_dns_zone_ids       = null  # Add private DNS zone IDs if needed

  # Diagnostics
  log_analytics_workspace_id = try(data.terraform_remote_state.security.outputs.log_analytics_workspace_id, null)

  tags = local.common_tags

  depends_on = [module.compute_rg]
}
#=============================================================================
# App Service Module
#=============================================================================

module "app_service" {
  count  = var.enable_app_service ? 1 : 0
  source = "../../modules/compute/app-service"

  service_plan_name   = "asp-${local.naming_prefix}"
  app_service_name    = "app-${local.naming_prefix}"
  location            = var.location
  resource_group_name = module.compute_rg.name

  # Service Plan Configuration
  os_type                      = var.app_service_os_type
  sku_name                     = local.app_service_config.sku_name
  worker_count                 = local.app_service_config.worker_count
  zone_balancing_enabled       = local.app_service_config.zone_balancing_enabled
  maximum_elastic_worker_count = local.app_service_config.maximum_elastic_worker_count

  # App Service Configuration
  https_only                    = true
  client_affinity_enabled       = false
  public_network_access_enabled = local.app_service_config.public_network_access_enabled
  vnet_integration_subnet_id    = var.enable_app_service_vnet_integration ? data.terraform_remote_state.networking.outputs.subnet_app_service_id : null

  # Identity
  identity_type = "SystemAssigned"
  identity_ids  = []

  # Site Configuration
  always_on                         = local.app_service_config.always_on
  ftps_state                        = "FtpsOnly"
  http2_enabled                     = true
  minimum_tls_version               = "1.2"
  vnet_route_all_enabled            = var.enable_app_service_vnet_integration
  websockets_enabled                = var.app_service_websockets_enabled
  health_check_path                 = var.app_service_health_check_path
  health_check_eviction_time_in_min = 10

  # Application Stack
  docker_image_name   = var.app_service_docker_image
  docker_registry_url = var.app_service_docker_registry_url
  dotnet_version      = var.app_service_dotnet_version
  java_version        = var.app_service_java_version
  node_version        = var.app_service_node_version
  php_version         = var.app_service_php_version
  python_version      = var.app_service_python_version
  windows_current_stack = var.app_service_windows_stack

  # Security
  ip_restrictions = var.app_service_ip_restrictions

  # CORS
  cors_allowed_origins     = var.app_service_cors_allowed_origins
  cors_support_credentials = var.app_service_cors_support_credentials

  # App Settings
  app_settings       = var.app_service_app_settings
  connection_strings = var.app_service_connection_strings

  # Logging
  detailed_error_messages  = true
  failed_request_tracing   = true
  app_log_level            = local.app_service_config.app_log_level
  http_logs_retention_days = local.app_service_config.http_logs_retention_days
  http_logs_retention_mb   = 35

  # Application Insights
  application_insights_key = null  # Set when monitoring layer is deployed

  # Deployment Slots
  enable_staging_slot = local.app_service_config.enable_staging_slot

  # Monitoring
  log_analytics_workspace_id = try(data.terraform_remote_state.security.outputs.log_analytics_workspace_id, null)

  tags = local.common_tags

  depends_on = [module.compute_rg]
}

#=============================================================================
# Web App Module
#=============================================================================

module "web_app" {
  count  = var.enable_web_app ? 1 : 0
  source = "../../modules/compute/web-app"

  name                = "app-${local.naming_prefix}-${local.location_short}"
  location            = var.location
  resource_group_name = module.compute_rg.name

  service_plan_name = "plan-${local.naming_prefix}-${local.location_short}"
  os_type           = var.web_app_os_type
  sku_name          = var.web_app_sku_name
  zone_redundant    = local.compute_config.web_app_zone_redundant

  # Security
  https_only                    = true
  minimum_tls_version           = "1.2"
  ftps_state                    = "Disabled"
  public_network_access_enabled = !local.compute_config.web_app_private_only

  # Networking
  vnet_integration_subnet_id = data.terraform_remote_state.networking.outputs.subnet_app_service_id
  vnet_route_all_enabled     = local.compute_config.web_app_vnet_route_all

  # Health Check
  health_check_path          = var.web_app_health_check_path
  health_check_eviction_time = var.web_app_health_check_eviction_time

  # Identity
  identity_type = var.web_app_identity_type
  identity_ids  = var.web_app_identity_ids

  # Application Stack
  application_stack = var.web_app_application_stack

  # App Settings
  app_settings = merge(
    var.web_app_app_settings,
    {
      "WEBSITE_RUN_FROM_PACKAGE"       = "1"
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
      "ENVIRONMENT"                    = var.environment
    }
  )

  # Connection Strings
  connection_strings = var.web_app_connection_strings

  # Logging
  detailed_error_messages   = var.web_app_detailed_error_messages
  failed_request_tracing    = var.web_app_failed_request_tracing
  enable_application_logs   = var.web_app_enable_application_logs
  application_logs_level    = var.web_app_application_logs_level
  enable_http_logs          = var.web_app_enable_http_logs
  http_logs_retention_days  = var.web_app_http_logs_retention_days
  http_logs_retention_mb    = var.web_app_http_logs_retention_mb

  # Private Endpoint
  enable_private_endpoint    = local.compute_config.web_app_private_only
  private_endpoint_subnet_id = local.compute_config.web_app_private_only ? data.terraform_remote_state.networking.outputs.subnet_private_endpoints_id : null
  private_dns_zone_ids       = []  # Add private DNS zone IDs when DNS layer is deployed

  # Monitoring
  log_analytics_workspace_id = null  # Add when monitoring layer is deployed

  tags = local.common_tags

  depends_on = [module.compute_rg]
}

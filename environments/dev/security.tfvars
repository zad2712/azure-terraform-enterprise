# Development Environment - Security Layer Configuration
# This file contains all security-related variables for the dev environment

# =============================================================================
# Environment Configuration
# =============================================================================
environment = "dev"
location    = "East US 2"

# State storage configuration
state_storage_account_name = "" # Will be set by pipeline
state_resource_group_name  = "" # Will be set by pipeline

# =============================================================================
# Key Vault Configuration
# =============================================================================
enable_key_vault                = true
key_vault_sku                  = "standard"  # Cost optimization for dev
key_vault_soft_delete_retention = 7          # Minimum retention for dev
key_vault_purge_protection      = false      # Disabled for dev flexibility

# =============================================================================
# Managed Identity Configuration
# =============================================================================
enable_user_assigned_identity = true

# =============================================================================
# Log Analytics Workspace Configuration
# =============================================================================
enable_log_analytics = true
log_retention_days   = 30    # Reduced retention for dev
log_analytics_sku    = "PerGB2018"

# =============================================================================
# Application Insights Configuration
# =============================================================================
enable_application_insights = true
application_type            = "web"

# =============================================================================
# Azure AD Integration
# =============================================================================
enable_azure_ad_integration = true

# =============================================================================
# Resource Tagging
# =============================================================================
tags = {
  Environment   = "dev"
  Owner        = "platform-team"
  CostCenter   = "engineering"
  Project      = "terraform-azure-enterprise"
  Workload     = "security"
  CreatedBy    = "terraform"
  CreatedDate  = "2025-01-15"
  
  # Cost management tags
  CostOptimized = "true"
  AutoShutdown  = "true"
  
  # Compliance tags
  Compliance    = "internal"
  DataClass     = "internal"
  
  # Operational tags
  Backup        = "not-required"
  Monitoring    = "basic"
  Support       = "business-hours"
}
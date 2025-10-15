/**
 * Application Insights Module
 * 
 * Creates an Application Insights instance for application performance monitoring
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

resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.workspace_id
  application_type    = var.application_type

  retention_in_days                     = var.retention_in_days
  daily_data_cap_in_gb                  = var.daily_data_cap_in_gb
  daily_data_cap_notifications_disabled = var.daily_data_cap_notifications_disabled
  sampling_percentage                   = var.sampling_percentage
  disable_ip_masking                    = var.disable_ip_masking
  internet_ingestion_enabled            = var.internet_ingestion_enabled
  internet_query_enabled                = var.internet_query_enabled
  local_authentication_disabled         = var.local_authentication_disabled

  tags = var.tags
}

# Web test (optional - for availability monitoring)
resource "azurerm_application_insights_standard_web_test" "this" {
  for_each = var.web_tests

  name                    = each.value.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.this.id
  geo_locations           = each.value.geo_locations
  frequency               = each.value.frequency
  timeout                 = each.value.timeout
  enabled                 = each.value.enabled

  request {
    url                              = each.value.url
    http_verb                        = lookup(each.value, "http_verb", "GET")
    parse_dependent_requests_enabled = lookup(each.value, "parse_dependent_requests", false)

    dynamic "header" {
      for_each = lookup(each.value, "headers", [])
      content {
        name  = header.value.name
        value = header.value.value
      }
    }
  }

  tags = var.tags
}

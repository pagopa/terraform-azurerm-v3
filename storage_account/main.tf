#tfsec:ignore:azure-storage-queue-services-logging-enabled
resource "azurerm_storage_account" "this" {
  name                             = var.name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_kind                     = var.account_kind
  account_tier                     = var.account_tier
  account_replication_type         = var.account_replication_type
  access_tier                      = var.access_tier
  enable_https_traffic_only        = true
  min_tls_version                  = var.min_tls_version
  allow_nested_items_to_be_public  = var.allow_nested_items_to_be_public
  is_hns_enabled                   = var.is_hns_enabled
  cross_tenant_replication_enabled = var.cross_tenant_replication_enabled

  dynamic "blob_properties" {
    for_each = ((var.account_kind == "BlockBlobStorage" || var.account_kind == "StorageV2") ? [1] : [])
    content {
      versioning_enabled = var.blob_versioning_enabled

      dynamic "delete_retention_policy" {
        for_each = (var.blob_delete_retention_days == 0 ? [] : [1])
        content {
          days = var.blob_delete_retention_days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = (var.container_delete_retention_days == 0 ? [] : [1])
        content {
          days = var.container_delete_retention_days
        }
      }
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules == null ? [] : [var.network_rules]

    content {
      default_action             = length(network_rules.value.ip_rules) == 0 && length(network_rules.value.virtual_network_subnet_ids) == 0 ? network_rules.value.default_action : "Deny"
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  dynamic "static_website" {
    for_each = var.index_document != null && var.error_404_document != null ? ["dummy"] : []

    content {
      index_document     = var.index_document
      error_404_document = var.error_404_document
    }
  }

  dynamic "custom_domain" {
    for_each = var.custom_domain.name != null ? ["dummy"] : []

    content {
      name          = var.custom_domain.name
      use_subdomain = var.custom_domain.use_subdomain
    }
  }

  tags = var.tags
}

# Enable advanced threat protection
resource "azurerm_advanced_threat_protection" "this" {
  target_resource_id = azurerm_storage_account.this.id
  enabled            = var.advanced_threat_protection
}

# -----------------------------------------------
# Alerts
# -----------------------------------------------

resource "azurerm_monitor_metric_alert" "storage_account_low_availability" {
  count = var.enable_low_availability_alert ? 1 : 0

  name                = "[${var.domain != null ? "${var.domain} | " : ""}${azurerm_storage_account.this.name}] Low Availability"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_storage_account.this.id]
  description         = "The average availability is less than 99.8%. Runbook: not needed."
  severity            = 0
  window_size         = "PT5M"
  frequency           = "PT5M"
  auto_mitigate       = false

  # Metric info
  # https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported#microsoftstoragestorageaccounts
  criteria {
    metric_namespace       = "Microsoft.Storage/storageAccounts"
    metric_name            = "Availability"
    aggregation            = "Average"
    operator               = "LessThan"
    threshold              = var.low_availability_threshold
    skip_metric_validation = false
  }

  dynamic "action" {
    for_each = var.action
    content {
      action_group_id    = action.value["action_group_id"]
      webhook_properties = action.value["webhook_properties"]
    }
  }

  tags = var.tags
}

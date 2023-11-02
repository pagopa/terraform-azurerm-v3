#
# Monitor Metrics
#
resource "azurerm_monitor_metric_alert" "replica_alerts" {
  for_each = var.replica_server_metric_alerts

  enabled             = var.alerts_enabled
  name                = "${var.name}-${upper(each.key)}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_postgresql_flexible_server.this.id]
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  severity            = each.value.severity

  dynamic "action" {
    for_each = var.alert_action
    content {
      # action_group_id - (required) is a type of string
      action_group_id = action.value["action_group_id"]
      # webhook_properties - (optional) is a type of map of string
      webhook_properties = action.value["webhook_properties"]
    }
  }

  criteria {
    aggregation      = each.value.aggregation
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    operator         = each.value.operator
    threshold        = each.value.threshold
  }
}

resource "azurerm_monitor_metric_alert" "main_server_alerts" {
  for_each = var.main_server_additional_alerts

  enabled             = var.alerts_enabled
  name                = "${var.name}-${upper(each.key)}"
  resource_group_name = var.resource_group_name
  scopes              = [var.source_server_id]
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  severity            = each.value.severity

  dynamic "action" {
    for_each = var.alert_action
    content {
      # action_group_id - (required) is a type of string
      action_group_id = action.value["action_group_id"]
      # webhook_properties - (optional) is a type of map of string
      webhook_properties = action.value["webhook_properties"]
    }
  }

  criteria {
    aggregation      = each.value.aggregation
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    operator         = each.value.operator
    threshold        = each.value.threshold
  }
}

##
## Diagnostic settings
##
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.diagnostic_settings_enabled ? 1 : 0
  name                       = "LogSecurity"
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.diagnostic_setting_destination_storage_id

  enabled_log {
    category = "PostgreSQLLogs"

    retention_policy {
      days    = 365
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert" "backup_alert" {
  for_each = var.alert_enabled ? toset(var.namespaces) : toset([])

  name                = "${var.backup_name}-${each.value}-execution-alert"
  location            = var.location
  resource_group_name = var.resource_group_name


   dynamic "action" {
    for_each = var.alert_action
    content {
      action_group = action.value["action_group_id"]
      custom_webhook_payload = action.value["webhook_properties"]
      email_subject          = "AKS backup for ${each.value} not performed"
    }
  }

  data_source_id = var.log_analytics_workspace_id
  description    = "Alert when AKS backup execution for namespace ${each.value} is missing"
  enabled        = true
  # Count all records containing "bakup completed" and the namespace of the backup of the backup
  query       = <<-QUERY
  ContainerLog
  | where LogEntry has "Backup completed"
  | where LogEntry has "${lower(each.value)}"
  | summarize count()
  QUERY
  severity    = 1
  frequency   = var.alert_frequency
  time_window = var.alert_window
  trigger {
    operator  = "LessThan"
    threshold = var.alert_min_events
  }
  tags = var.tags
}

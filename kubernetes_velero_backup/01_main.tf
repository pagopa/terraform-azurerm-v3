resource "null_resource" "schedule_backup" {
  for_each = toset(var.namespaces)

  triggers = {
    backup_name     = var.backup_name
    schedule        = var.schedule
    volume_snapshot = var.volume_snapshot
    ttl             = var.ttl
    namespace       = each.value
    cluster_name    = var.aks_cluster_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    kubectl config use-context "${self.triggers.cluster_name}" && \
    velero schedule delete ${self.triggers.backup_name}-${self.triggers.namespace} --confirm
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
    kubectl config use-context "${self.triggers.cluster_name}" && \
    velero schedule create ${lower(self.triggers.backup_name)}-${lower(self.triggers.namespace)} --schedule="${var.schedule}" --ttl ${var.ttl} %{if each.value != "ALL"} --include-namespaces ${each.value} %{endif} --snapshot-volumes=${var.volume_snapshot}
    EOT
  }
}



resource "azurerm_monitor_scheduled_query_rules_alert" "backup_alert" {
  for_each = toset(var.namespaces)

  name                = "${var.prefix}-velero-backup-${each.value}"
  location            = var.location
  resource_group_name = var.rg_name

  action {
    action_group = var.action_group_ids
  }
  data_source_id = var.cluster_id
  description    = "Alert when no backup '${var.backup_name}-${lower(each.value)}' performed in the last ${var.alert_time_window} minutes"
  enabled        = var.alert_enabled
  query          = <<-QUERY
  ContainerLog
  | where LogEntry contains "Backup completed"
  | where LogEntry contains "${var.backup_name}-${lower(each.value)}"
  | summarize AggregatedValue = count()
  QUERY
  severity       = var.alert_severity
  frequency      = var.alert_frequency
  time_window    = var.alert_time_window
  trigger {
    operator  = "LessThan"
    threshold = var.alert_threshold
  }
  tags = var.tags
}

locals {
  alert_rules      = jsondecode(file("${path.module}/rules/alert_rules.json"))
  action_groups_id = var.action_groups_id
}


resource "azurerm_monitor_alert_prometheus_rule_group" "recording_rules_alert_group" {
  name                = "MProm-Alerts-${var.cluster_name}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  cluster_name        = var.cluster_name
  description         = "Alerts Rule Group"
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes = [
    azurerm_monitor_workspace.this.id,
    data.azurerm_kubernetes_cluster.this.id
  ]
  tags = var.tags

  dynamic "rule" {
    for_each = local.alert_rules
    content {
      alert   = rule.value.alert
      enabled = rule.value.enabled

      expression = rule.value.expression
      for        = rule.value.for
      severity   = rule.value.severity

      labels = {
        severity = rule.value.severity_label
      }

      dynamic "action" {
        for_each = local.action_groups_id
        content {
          action_group_id = action.value
        }
      }

      alert_resolution {
        auto_resolved   = rule.value.alert_resolution.auto_resolved
        time_to_resolve = rule.value.alert_resolution.time_to_resolve
      }

      annotations = {
        summary     = rule.value.annotations.summary
        description = rule.value.annotations.description
      }
    }
  }
}

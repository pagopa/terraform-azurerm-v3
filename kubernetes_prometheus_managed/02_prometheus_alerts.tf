locals {
  alert_rules_cluster_nodes = jsondecode(file("${path.module}/rules/alert_rules_cluster_nodes.json"))
  alert_rules_pods          = jsondecode(file("${path.module}/rules/alert_rules_pod.json"))
  action_groups_id          = var.action_groups_id
}


resource "azurerm_monitor_alert_prometheus_rule_group" "recording_rules_alert_group_cluster_nodes" {
  count               = var.enable_prometheus_alerts ? 1 : 0
  name                = "MProm-ClusterNodes-Alerts-${var.cluster_name}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  cluster_name        = var.cluster_name
  description         = "Cluster And Nodes Alerts Rule Group"
  rule_group_enabled  = var.enable_alerts
  interval            = "PT1M"
  scopes = [
    data.azurerm_monitor_workspace.this.id,
    data.azurerm_kubernetes_cluster.this.id
  ]
  tags = var.tags

  dynamic "rule" {
    for_each = local.alert_rules_cluster_nodes
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

resource "azurerm_monitor_alert_prometheus_rule_group" "recording_rules_alert_group_pods" {
  count               = var.enable_prometheus_alerts ? 1 : 0
  name                = "MProm-Pods-Alerts-${var.cluster_name}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  cluster_name        = var.cluster_name
  description         = "Pods Alerts Rule Group"
  rule_group_enabled  = var.enable_alerts
  interval            = "PT1M"
  scopes = [
    data.azurerm_monitor_workspace.this.id,
    data.azurerm_kubernetes_cluster.this.id
  ]
  tags = var.tags

  dynamic "rule" {
    for_each = local.alert_rules_pods
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

resource "azurerm_monitor_alert_prometheus_rule_group" "node_recording_rules_alert_group" {
  name                = "NodeRecordingRulesRuleGroup-Alerts-${var.cluster_name}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  cluster_name        = var.cluster_name
  description         = "Node Recording Alerts Rule Group"
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes = [
    azurerm_monitor_workspace.this.id, data.azurerm_kubernetes_cluster.this.id
  ]
  tags = var.tags

  rule {
    alert      = "HighNodeCPUUsage"
    expression = "avg by (instance) (rate(node_cpu_seconds_total{mode!='idle'}[5m])) > 0.08"
    for        = "15m"
    labels = {
      severity = "warning"
    }
    annotations = {
      summary     = "Elevato utilizzo della CPU del nodo rilevato"
      description = "L'utilizzo medio della CPU per il nodo {{ $labels.instance }} ha superato l'80% per più di 10 minuti."
    }
  }
}

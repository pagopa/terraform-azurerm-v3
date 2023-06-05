#
# Monitor Metrics
#
resource "azurerm_monitor_metric_alert" "this" {
  for_each = local.metric_alerts

  name                = "${azurerm_kubernetes_cluster.this.name}-${upper(each.key)}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_kubernetes_cluster.this.id]
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  enabled             = var.alerts_enabled

  dynamic "action" {
    for_each = var.action
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

    dynamic "dimension" {
      for_each = each.value.dimension
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }

  depends_on = [
    azurerm_kubernetes_cluster.this
  ]
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  count                      = var.sec_log_analytics_workspace_id != null ? 1 : 0
  name                       = "LogSecurity"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.sec_log_analytics_workspace_id
  storage_account_id         = var.sec_storage_id

  enabled_log {
    category = "kube-audit"

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "kube-audit-admin"

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "cloud-controller-manager"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "cluster-autoscaler"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "csi-azuredisk-controller"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "csi-azurefile-controller"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "csi-snapshot-controller"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "guard"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "kube-apiserver"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "kube-controller-manager"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "kube-scheduler"

    retention_policy {
      enabled = false
      days    = 0
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


  depends_on = [
    azurerm_kubernetes_cluster.this
  ]
}

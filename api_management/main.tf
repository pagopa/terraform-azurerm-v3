resource "azurerm_api_management" "this" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  publisher_name            = var.publisher_name
  publisher_email           = var.publisher_email
  notification_sender_email = var.notification_sender_email
  sku_name                  = var.sku_name

  # deprecated var.policy_path use xml_content
  dynamic "policy" {
    for_each = var.policy_path != null ? ["dummy"] : []
    content {
      xml_content = file(var.policy_path)
    }
  }

  dynamic "policy" {
    for_each = var.xml_content != null ? ["dummy"] : []
    content {
      xml_content = var.xml_content
    }
  }

  # Managed identity type: System
  identity {
    type = "SystemAssigned"
  }

  virtual_network_type = var.virtual_network_type

  # subnet
  dynamic "virtual_network_configuration" {
    for_each = contains(["Internal", "External"], var.virtual_network_type) ? ["dummy"] : []
    content {
      subnet_id = var.subnet_id
    }
  }

  dynamic "sign_up" {
    for_each = var.sign_up_enabled == true ? ["dummy"] : []
    content {
      enabled = var.sign_up_enabled
      terms_of_service {
        enabled          = var.sign_up_terms_of_service.enabled
        consent_required = var.sign_up_terms_of_service.consent_required
        text             = var.sign_up_terms_of_service.text
      }
    }
  }

  dynamic "hostname_configuration" {
    for_each = var.hostname_configuration != null ? ["dummy"] : []
    content {
      dynamic "proxy" {
        for_each = var.hostname_configuration.proxy
        iterator = domain
        content {
          default_ssl_binding = domain.value.default_ssl_binding
          host_name           = domain.value.host_name
          key_vault_id        = domain.value.key_vault_id
        }
      }
      dynamic "management" {
        for_each = var.hostname_configuration.management != null ? ["dummy"] : []
        iterator = domain
        content {
          host_name    = var.hostname_configuration.management.host_name
          key_vault_id = var.hostname_configuration.management.key_vault_id
        }
      }
      dynamic "portal" {
        for_each = var.hostname_configuration.portal != null ? ["dummy"] : []
        iterator = domain
        content {
          host_name    = var.hostname_configuration.portal.host_name
          key_vault_id = var.hostname_configuration.portal.key_vault_id
        }
      }
      dynamic "developer_portal" {
        for_each = var.hostname_configuration.developer_portal != null ? ["dummy"] : []
        iterator = domain
        content {
          host_name    = var.hostname_configuration.developer_portal.host_name
          key_vault_id = var.hostname_configuration.developer_portal.key_vault_id
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      sku_name,
    ]
  }
}

# only Premium sku support autoscaling
resource "azurerm_monitor_autoscale_setting" "this" {
  count               = var.sku_name == "Premium_1" && var.autoscale != null && var.autoscale.enabled ? 1 : 0
  name                = "${azurerm_api_management.this.name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_api_management.this.id

  profile {
    name = "default"

    capacity {
      default = var.autoscale.default_instances
      minimum = var.autoscale.minimum_instances
      maximum = var.autoscale.maximum_instances
    }

    rule {
      metric_trigger {
        metric_name              = "Capacity"
        metric_resource_id       = azurerm_api_management.this.id
        metric_namespace         = "microsoft.apimanagement/service"
        time_grain               = "PT1M"
        statistic                = "Average"
        time_window              = var.autoscale.scale_out_time_window
        time_aggregation         = "Average"
        operator                 = "GreaterThan"
        threshold                = var.autoscale.scale_out_capacity_percentage
        divide_by_instance_count = false
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = var.autoscale.scale_out_value
        cooldown  = var.autoscale.scale_out_cooldown
      }
    }

    rule {
      metric_trigger {
        metric_name              = "Capacity"
        metric_resource_id       = azurerm_api_management.this.id
        metric_namespace         = "microsoft.apimanagement/service"
        time_grain               = "PT1M"
        statistic                = "Average"
        time_window              = var.autoscale.scale_in_time_window
        time_aggregation         = "Average"
        operator                 = "LessThan"
        threshold                = var.autoscale.scale_in_capacity_percentage
        divide_by_instance_count = false
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = var.autoscale.scale_in_value
        cooldown  = var.autoscale.scale_in_cooldown
      }
    }
  }
}

#
# Diagnostic, Logs & Monitor
#
resource "azurerm_api_management_logger" "this" {
  count = var.application_insights.enabled ? 1 : 0

  name                = "${var.name}-logger"
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name

  application_insights {
    instrumentation_key = var.application_insights.instrumentation_key
  }
}

resource "azurerm_api_management_diagnostic" "this" {
  count = var.application_insights.enabled ? 1 : 0

  identifier               = "applicationinsights"
  resource_group_name      = var.resource_group_name
  api_management_name      = azurerm_api_management.this.name
  api_management_logger_id = azurerm_api_management_logger.this[0].id

  sampling_percentage       = var.diagnostic_sampling_percentage
  always_log_errors         = var.diagnostic_always_log_errors
  log_client_ip             = var.diagnostic_log_client_ip
  verbosity                 = var.diagnostic_verbosity
  http_correlation_protocol = var.diagnostic_http_correlation_protocol


  dynamic "backend_request" {
    for_each = var.diagnostic_backend_request
    content {
      # body_bytes - (optional) is a type of number
      body_bytes = backend_request.value["body_bytes"]
      # headers_to_log - (optional) is a type of set of string
      headers_to_log = backend_request.value["headers_to_log"]
    }
  }

  dynamic "backend_response" {
    for_each = var.diagnostic_backend_response
    content {
      # body_bytes - (optional) is a type of number
      body_bytes = backend_response.value["body_bytes"]
      # headers_to_log - (optional) is a type of set of string
      headers_to_log = backend_response.value["headers_to_log"]
    }
  }

  dynamic "frontend_request" {
    for_each = var.diagnostic_frontend_request
    content {
      # body_bytes - (optional) is a type of number
      body_bytes = frontend_request.value["body_bytes"]
      # headers_to_log - (optional) is a type of set of string
      headers_to_log = frontend_request.value["headers_to_log"]
    }
  }

  dynamic "frontend_response" {
    for_each = var.diagnostic_frontend_response
    content {
      # body_bytes - (optional) is a type of number
      body_bytes = frontend_response.value["body_bytes"]
      # headers_to_log - (optional) is a type of set of string
      headers_to_log = frontend_response.value["headers_to_log"]
    }
  }
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each = var.metric_alerts

  name                = "${azurerm_api_management.this.name}-${upper(each.key)}"
  description         = each.value.description
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_api_management.this.id]
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  severity            = each.value.severity
  auto_mitigate       = each.value.auto_mitigate
  enabled             = var.alerts_enabled

  dynamic "action" {
    for_each = var.action
    content {
      action_group_id    = action.value["action_group_id"]
      webhook_properties = action.value["webhook_properties"]
    }
  }

  dynamic "criteria" {
    for_each = each.value.criteria
    content {
      aggregation            = criteria.value["aggregation"]
      metric_name            = criteria.value["metric_name"]
      metric_namespace       = criteria.value["metric_namespace"]
      operator               = criteria.value["operator"]
      skip_metric_validation = criteria.value["skip_metric_validation"]
      threshold              = criteria.value["threshold"]

      dynamic "dimension" {
        for_each = criteria.value.dimension
        content {
          name     = dimension.value["name"]
          operator = dimension.value["operator"]
          values   = dimension.value["values"]
        }
      }

    }
  }

  dynamic "dynamic_criteria" {
    for_each = each.value.dynamic_criteria
    content {
      aggregation              = dynamic_criteria.value["aggregation"]
      alert_sensitivity        = dynamic_criteria.value["alert_sensitivity"]
      evaluation_failure_count = dynamic_criteria.value["evaluation_failure_count"]
      evaluation_total_count   = dynamic_criteria.value["evaluation_total_count"]
      ignore_data_before       = dynamic_criteria.value["ignore_data_before"]
      metric_name              = dynamic_criteria.value["metric_name"]
      metric_namespace         = dynamic_criteria.value["metric_namespace"]
      operator                 = dynamic_criteria.value["operator"]
      skip_metric_validation   = dynamic_criteria.value["skip_metric_validation"]

      dynamic "dimension" {
        for_each = dynamic_criteria.value.dimension
        content {
          name     = dimension.value["name"]
          operator = dimension.value["operator"]
          values   = dimension.value["values"]
        }
      }

    }
  }
}

#
# 🧺 REDIS
#
resource "azurerm_api_management_redis_cache" "this" {
  count = var.redis_connection_string != null ? 1 : 0

  name              = format("%s-redis", var.name)
  api_management_id = azurerm_api_management.this.id
  connection_string = var.redis_connection_string
  redis_cache_id    = var.redis_cache_id
}

#
# Certificate
#
data "azurerm_key_vault_certificate" "key_vault_certificate" {
  count        = var.key_vault_id != null ? length(var.certificate_names) : 0
  name         = var.certificate_names[count.index]
  key_vault_id = var.key_vault_id
}

resource "azurerm_api_management_certificate" "this" {
  count               = var.key_vault_id != null ? length(var.certificate_names) : 0
  name                = var.certificate_names[count.index]
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name

  key_vault_secret_id = trimsuffix(data.azurerm_key_vault_certificate.key_vault_certificate[count.index].secret_id, data.azurerm_key_vault_certificate.key_vault_certificate[count.index].version)
}

#
# Diagnostic settings
#
resource "azurerm_monitor_diagnostic_setting" "apim" {
  count                          = var.sec_log_analytics_workspace_id != null ? 1 : 0
  name                           = "LogSecurity"
  target_resource_id             = azurerm_api_management.this.id
  log_analytics_workspace_id     = var.sec_log_analytics_workspace_id
  storage_account_id             = var.sec_storage_id
  log_analytics_destination_type = "AzureDiagnostics"

  enabled_log {
    category = "GatewayLogs"

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "WebSocketConnectionLogs"

    retention_policy {
      enabled = true
      days    = 365
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

#
# Other
#
resource "azurerm_management_lock" "this" {
  count      = var.lock_enable ? 1 : 0
  name       = "${azurerm_api_management.this.name}-lock"
  scope      = azurerm_api_management.this.id
  lock_level = "CanNotDelete"
  notes      = "This items can't be deleted in this subscription!"
}

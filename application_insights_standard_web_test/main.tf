locals {
  all_header_json = jsondecode(var.https_probe_headers)
  all_headers_value = flatten([
    for k, v in local.all_header_json : {
      headervalue = v
      headername  = k
    }
  ])
}

resource "azurerm_application_insights_standard_web_test" "this" {
  name                    = local.alert_name
  resource_group_name     = var.application_insights_resource_group
  location                = var.location
  application_insights_id = var.application_insights_id
  geo_locations           = ["emea-nl-ams-azr"]
  description             = "HTTP Standard WebTests"
  frequency               = var.frequency
  enabled                 = var.alert_enabled

  request {
    url       = format("%s%s", var.https_endpoint, var.https_endpoint_path)
    body      = var.https_probe_body
    http_verb = var.https_probe_method

    dynamic "header" {
      for_each = local.all_headers_value

      content {
        name  = header.value.headername
        value = header.value.headervaule
      }
    }
  }

}

## migrate to Microsoft.Insights/webTests 

resource "azurerm_monitor_metric_alert" "alert_this" {
  name                = local.alert_name
  resource_group_name = var.application_insights_resource_group
  scopes              = [var.application_insights_id]
  description         = "Whenever the average availabilityresults/availabilitypercentage is less than ${var.https_probe_threshold}%"
  severity            = var.metric_severity
  frequency           = var.metric_frequency
  auto_mitigate       = false
  enabled             = var.alert_enabled

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.https_probe_threshold

    dimension {
      name     = "availabilityResult/name"
      operator = "Include"
      values   = [local.alert_name]
    }

  }

  dynamic "action" {
    for_each = var.application_insights_action_group_ids

    content {
      action_group_id = action.value
    }
  }

  depends_on = [
    azurerm_application_insights_standard_web_test.this
  ]
}
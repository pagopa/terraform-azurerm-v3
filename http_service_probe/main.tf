locals {
  all_header_json = jsondecode(var.https_probe_headers)
  all_headers_value = flatten([
    for k, v in local.all_header_json : {
      valore = v
      chiave = k
    }
  ])
}

resource "azurerm_application_insights_standard_web_test" "this" {
  name                    = local.alert_name
  resource_group_name     = var.application_insights_resource_group
  location                = "West Europe"
  application_insights_id = var.application_insights_id
  geo_locations           = ["emea-nl-ams-azr"]
  description         = "HTTP service probe"
  frequency           = "300"
  enabled             = var.alert_enabled

  request {
    url = format("%s%s",var.https_endpoint, var.https_endpoint_path)
    body  = var.body != null ? var.body : null
    http_verb = "GET"
    
    dynamic "header" {
        for_each = local.all_headers_value

        content {
          name = header.value.chiave
          value = header.value.valore
        }
    }
  }

}

## migrate to Microsoft.Insights/webTests after GA

resource "azurerm_monitor_metric_alert" "alert_this" {
  name                = local.alert_name
  resource_group_name = var.application_insights_resource_group
  scopes              = [var.application_insights_id]
  description         = "Whenever the average availabilityresults/availabilitypercentage is less than 90%"
  severity            = 0
  frequency           = "PT5M"
  auto_mitigate       = false
  enabled             = var.alert_enabled

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 90

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
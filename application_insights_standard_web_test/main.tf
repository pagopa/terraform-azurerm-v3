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
  description             = "HTTP Standard WebTests ${local.alert_name} running on: emea-nl-ams-azr"
  frequency               = var.frequency
  enabled                 = var.alert_enabled
  retry_enabled           = var.retry_enabled
  timeout                 = var.timeout

  request {
    url       = "${var.https_endpoint}${var.https_endpoint_path}"
    body      = var.https_probe_body
    http_verb = var.https_probe_method
    follow_redirects_enabled = var.request_follow_redirects
    parse_dependent_requests_enabled = var.request_parse_dependent_requests_enabled

    dynamic "header" {
      for_each = local.all_headers_value

      content {
        name  = header.value.headername
        value = header.value.headervalue
      }
    }
  }

  dynamic "validation_rules" {
    for_each = var.validation_rules != null ? [1] : []
    content {
      expected_status_code = var.validation_rules.expected_status_code
      ssl_cert_remaining_lifetime = var.validation_rules.ssl_cert_remaining_lifetime
      ssl_check_enabled = var.validation_rules.ssl_check_enabled
      dynamic "content"{
        for_each = var.validation_rules.content != null ? [1] : []
        content {
          content_match = var.validation_rules.content.content_match
          ignore_case = var.validation_rules.content.ignore_case
          pass_if_text_found = var.validation_rules.content.pass_if_text_found
        }
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
  window_size         = var.metric_window_size

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

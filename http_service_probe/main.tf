resource "azurerm_application_insights_standard_web_test" "this" {
  name                    = local.alert_name
  resource_group_name     = var.application_insights_resource_group
  location                = "West Europe"
  application_insights_id = var.application_insights_id
  geo_locations           = ["emea-nl-ams-azr"]
  description         = "HTTP service probe"
  severity            = 0
  frequency           = "PT5M"
  enabled             = var.alert_enabled

  request {
    url = format("%s%s",var.https_endpoint, var.https_endpoint_path)
    body  = []
    http_verb = "GET"

  }

  dynamic "header" {
    for_each = var.https_probe_headers

    content {
      name = header.name.value
      value = header.value.value
    }
  }

  validation_rules {
    expected_status_code = "0"
  }

}

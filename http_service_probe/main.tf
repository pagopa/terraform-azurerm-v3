locals {
  all_headers_value = flatten([
    for k, v in var.https_probe_headers : {
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
    body  = ""
    http_verb = "GET"
    
    dynamic "header" {
        for_each = { for i, v in local.all_headers_value : local.all_headers_value[i].chiave => i }

        content {
          name = header.chiave.value
          value = header.valore.value
        }
    }
  }

}

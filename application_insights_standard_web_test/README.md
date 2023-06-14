# Application insights standard web test

This module create an alert for a http(s) webservice

# Example

module "webservice_monitor_01" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//application_insights_standard_web_test?ref=vX.X.X"
  

  https_endpoint                         = "https://api.dev.platform.pagopa.it"
  https_endpoint_path                    = "/contextpath/rest"
  alert_name                             = "WebServiceProbeName"
  location                               = var.location
  alert_enabled                          = true
  application_insights_resource_group    = data.azurerm_resource_group.monitor_rg.name
  application_insights_id                = data.azurerm_application_insights.application_insights.id
  https_probe_headers                    = "{\"NomeHeader\":\"ValoreHeader\"}"
  application_insights_action_group_ids  = [data.azurerm_monitor_action_group.slack.id, data.azurerm_monitor_action_group.email.id]
  https_probe_body                       = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" ....  </soapenv:Envelope>"
  https_probe_method                     = "POST"
}
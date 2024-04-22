resource "azurerm_resource_group" "vnet_alert_rg" {
  name     = "rg_fake_vnet_alert"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "alert_rg" {
  name     = "rg_fake_alert"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-fake-alert"
  resource_group_name = "vnet-fake-alert-rg"
  location            = var.location
  address_space       = ["10.3.200.0/16"]
}

## alert subnet
module "alert_snet" {
  source                                    = "../../subnet"
  name                                      = "${local.project}-alert-snet"
  address_prefixes                          = ["10.3.201.0/24"]
  resource_group_name                       = azurerm_resource_group.vnet_alert_rg.name
  virtual_network_name                      = azurerm_virtual_network.this.name
  service_endpoints                         = ["Microsoft.alert"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_private_dns_zone" "external_zone" {
  name                = "${local.project}-private-dns-zone"
  resource_group_name = azurerm_resource_group.vnet_alert_rg.name
}



#--------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg_alert" {
  name     = "${local.project}-alert-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "monitor_rg" {
  name     = "${local.project}-alert-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_application_insights" "application_insights" {
  name                = "tf-test-appinsights"
  location            = azurerm_resource_group.monitor_rg.location
  resource_group_name = azurerm_resource_group.monitor_rg.name
  application_type    = "web"
}


module "__web_test_legacy" {
  source = "../../application_insights_standard_web_test"

  https_endpoint                         = "https://api.dev.platform.pagopa.it"
  https_endpoint_path                    = "/contextpath/rest"
  alert_name                             = "WebServiceProbeName"
  location                               = var.location
  alert_enabled                          = true
  application_insights_resource_group    = azurerm_resource_group.monitor_rg.name
  application_insights_id                = azurerm_application_insights.application_insights.id
  https_probe_headers                    = "{\"HeaderName\":\"HeaderValue\"}"
  application_insights_action_group_ids  = []
  https_probe_body                       = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" ....  </soapenv:Envelope>"
  https_probe_method                     = "POST"
}

module "__web_test_all" {
  source = "../../application_insights_standard_web_test"

  https_endpoint                         = "https://api.dev.platform.pagopa.it"
  https_endpoint_path                    = "/contextpath/rest"
  alert_name                             = "WebServiceProbeName"
  location                               = var.location
  alert_enabled                          = true
  application_insights_resource_group    = azurerm_resource_group.monitor_rg.name
  application_insights_id                = azurerm_application_insights.application_insights.id
  https_probe_headers                    = "{\"HeaderName\":\"HeaderValue\"}"
  application_insights_action_group_ids  = []
  https_probe_body                       = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" ....  </soapenv:Envelope>"
  https_probe_method                     = "POST"
  retry_enabled = true
  timeout = 60

  metric_window_size = "PT30M"
}

data "azurerm_virtual_network" "vnet" {
  name                = "dvopla-d-azdoa-rg-vnet"
  resource_group_name = "dvopla-d-azdoa-rg"
}

data "azurerm_resource_group" "rg_vnet" {
  name = "dvopla-d-azdoa-rg"
}

## Eventhub subnet
module "eventhub_snet" {
  source                                    = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v7.29.0"
  name                                      = "${local.project}-eventhub-snet"
  address_prefixes                          = ["10.3.200.0/24"]
  resource_group_name                       = data.azurerm_resource_group.rg_vnet.name
  virtual_network_name                      = data.azurerm_virtual_network.vnet.name
  service_endpoints                         = ["Microsoft.EventHub"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_resource_group" "rg_eventhub" {
  name     = "${local.project}-eventhub-rg"
  location = var.location

  tags = var.tags
}

module "event_hub" {
  source = "../../eventhub"

  name                     = "${local.project}-evh-ns"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg_eventhub.name
  auto_inflate_enabled     = false
  sku                      = "Standard"
  zone_redundant           = true

  virtual_network_ids = [data.azurerm_virtual_network.vnet.id]
  subnet_id           = module.eventhub_snet.id

  eventhubs = [{
    name              = "rtd-trx"
    partitions        = 1
    message_retention = 1
    consumers         = [
      "bpd-payment-instrument",
      "rtd-trx-fa-comsumer-group",
      "idpay-consumer-group"
    ]
    keys = [
      {
        name   = "rtd-csv-connector"
        listen = false
        send   = true
        manage = false
      },
      {
        name   = "bpd-payment-instrument"
        listen = true
        send   = false
        manage = false
      },
    ]
  }]

  alerts_enabled = false
  # metric_alerts  = var.ehns_metric_alerts

  tags = var.tags
}

module "event_hub_core_only" {
  source = "../../eventhub"

  name                     = "${local.project}-evh-core-ns"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg_eventhub.name
  auto_inflate_enabled     = false
  sku                      = "Standard"
  zone_redundant           = true

  virtual_network_ids = [data.azurerm_virtual_network.vnet.id]
  subnet_id           = module.eventhub_snet.id

  alerts_enabled = false

  tags = var.tags
}

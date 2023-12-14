data "azurerm_virtual_network" "vnet" {
  name                = "dvopla-d-azdoa-rg-vnet"
  resource_group_name = "dvopla-d-azdoa-rg"
}

data "azurerm_resource_group" "rg_vnet" {
  name = "dvopla-d-azdoa-rg"
}

module "private_endpoint_snet" {
  source                                    = "../../subnet"
  name                                      = "${local.project}-pe-snet"
  address_prefixes                          = ["10.3.200.0/27"]
  resource_group_name                       = data.azurerm_resource_group.rg_vnet.name
  virtual_network_name                      = data.azurerm_virtual_network.vnet.name
  private_endpoint_network_policies_enabled = true
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

resource "azurerm_private_dns_zone" "external_zone" {
  name                = "${local.project}-private-dns-zone"
  resource_group_name = data.azurerm_resource_group.rg_vnet.name
}

#--------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg_eventhub" {
  name     = "${local.project}-eventhub-rg"
  location = var.location

  tags = var.tags
}

module "event_hub_core_only" {
  source = "../../eventhub"

  name                 = "${local.project}-evh-core-ns"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg_eventhub.name
  auto_inflate_enabled = false
  sku                  = "Standard"
  zone_redundant       = true

  virtual_network_ids = [data.azurerm_virtual_network.vnet.id]

  private_endpoint_created = false

  alerts_enabled = false

  tags = var.tags
}

module "event_hub_core_only_configuration" {

  source = "../../eventhub_configuration"

  event_hub_namespace_name                = "${local.project}-evh-core-ns"
  event_hub_namespace_resource_group_name = azurerm_resource_group.rg_eventhub.name

  eventhubs = [{
    name              = "rtd-trx"
    partitions        = 1
    message_retention = 1
    consumers = [
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

}


module "event_hub_core_network" {
  source = "../../eventhub"

  name                 = "${local.project}-evh-with-network-ns"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg_eventhub.name
  auto_inflate_enabled = false
  sku                  = "Standard"
  zone_redundant       = true

  virtual_network_ids = [data.azurerm_virtual_network.vnet.id]

  private_endpoint_created             = true
  private_endpoint_subnet_id           = module.private_endpoint_snet.id
  private_endpoint_resource_group_name = data.azurerm_resource_group.rg_vnet.name

  private_dns_zones = {
    id                  = [azurerm_private_dns_zone.external_zone.id]
    name                = [azurerm_private_dns_zone.external_zone.name]
    resource_group_name = azurerm_private_dns_zone.external_zone.resource_group_name
  }

  alerts_enabled = false

  tags = var.tags
}

module "event_hub_core_network_configuration" {

  source = "../../eventhub_configuration"

  event_hub_namespace_name                = "${local.project}-evh-with-network-ns"
  event_hub_namespace_resource_group_name = azurerm_resource_group.rg_eventhub.name

  eventhubs = [{
    name              = "rtd-trx"
    partitions        = 1
    message_retention = 1
    consumers = [
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

}

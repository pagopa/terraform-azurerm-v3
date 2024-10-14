resource "azurerm_resource_group" "vnet_eventhub_rg" {
  name     = "rg_fake_vnet_eventhub"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "eventhub_rg" {
  name     = "rg_fake_eventhub"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-fake-eventhub"
  resource_group_name = "vnet-fake-eventhub-rg"
  location            = var.location
  address_space       = ["10.3.200.0/16"]
}

module "private_endpoint_snet" {
  source                                    = "../../subnet"
  name                                      = "${local.project}-pe-snet"
  address_prefixes                          = ["10.3.200.0/24"]
  resource_group_name                       = azurerm_resource_group.vnet_eventhub_rg.name
  virtual_network_name                      = azurerm_virtual_network.this.name
  private_endpoint_network_policies_enabled = true
}

## Eventhub subnet
module "eventhub_snet" {
  source                                    = "../../subnet"
  name                                      = "${local.project}-eventhub-snet"
  address_prefixes                          = ["10.3.201.0/24"]
  resource_group_name                       = azurerm_resource_group.vnet_eventhub_rg.name
  virtual_network_name                      = azurerm_virtual_network.this.name
  service_endpoints                         = ["Microsoft.EventHub"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_private_dns_zone" "external_zone" {
  name                = "${local.project}-private-dns-zone"
  resource_group_name = azurerm_resource_group.vnet_eventhub_rg.name
}

#--------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg_eventhub" {
  name     = "${local.project}-eventhub-rg"
  location = var.location

  tags = var.tags
}

module "event_hub_complete" {
  source = "../../eventhub"

  name                 = "${local.project}-evh-complete-ns"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg_eventhub.name
  auto_inflate_enabled = false
  sku                  = "Standard"
  zone_redundant       = true

  virtual_network_ids = [azurerm_virtual_network.this.id]

  internal_private_dns_zone_created             = true
  internal_private_dns_zone_resource_group_name = "dvopla-eventhub-private-dns-zone-rg"

  private_endpoint_created             = true
  private_endpoint_resource_group_name = "dvopla-d-azdoa-rg"
  # use a dedicated subnet for private endpoints, this is only for example
  private_endpoint_subnet_id = module.eventhub_snet.id

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

  metric_alerts_create = false

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

  virtual_network_ids = [azurerm_virtual_network.this.id]

  private_endpoint_created = false

  metric_alerts_create = false

  tags = var.tags
}

module "event_hub_core_network" {
  source = "../../eventhub"

  name                 = "${local.project}-evh-with-network-ns"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg_eventhub.name
  auto_inflate_enabled = false
  sku                  = "Standard"
  zone_redundant       = true

  virtual_network_ids = [azurerm_virtual_network.this.id]

  private_endpoint_created             = true
  private_endpoint_subnet_id           = module.private_endpoint_snet.id
  private_endpoint_resource_group_name = azurerm_resource_group.vnet_eventhub_rg.name

  private_dns_zones = {
    id                  = [azurerm_private_dns_zone.external_zone.id]
    name                = [azurerm_private_dns_zone.external_zone.name]
    resource_group_name = azurerm_private_dns_zone.external_zone.resource_group_name
  }

  metric_alerts_create = false

  tags = var.tags
}

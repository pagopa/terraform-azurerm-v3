resource "azurerm_resource_group" "rg" {
  name     = "rg-data-indexer"
  location = var.location

  tags = var.tags
}

module "key_vault" {
  source                     = "../../key_vault"
  name                       = format("%s-kv", local.project)
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  soft_delete_retention_days = 15
  lock_enable                = false
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_servicebus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "servicebus_private_vnet" {
  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_servicebus.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false

  tags = var.tags
}

module "pendpoints_snet" {
  source                                    = "../../subnet"
  name                                      = format("%s-pendpoints-snet", local.project)
  address_prefixes                          = var.cidr_subnet_pendpoints
  resource_group_name                       = azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  service_endpoints                         = ["Microsoft.EventHub"]
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_private_dns_zone" "privatelink_blob_core" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_core_private_vnet_in_common" {
  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_blob_core.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false

  tags = var.tags
}

module "eventhub_snet" {
  source                                    = "../../subnet"
  name                                      = format("%s-eventhub-snet", local.project)
  address_prefixes                          = var.cidr_subnet_eventhub
  resource_group_name                       = azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  service_endpoints                         = ["Microsoft.EventHub"]
  private_endpoint_network_policies_enabled = false
}

module "event_hub" {
  source                   = "../../eventhub"
  name                     = format("%s-evh-ns", local.project)
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  sku                      = "Basic"
  zone_redundant           = true
  virtual_network_ids = [azurerm_virtual_network.vnet.id]
  subnet_id           = module.eventhub_snet.id
  private_dns_zones = {
    id   = [azurerm_private_dns_zone.privatelink_servicebus.id]
    name = [azurerm_private_dns_zone.privatelink_servicebus.name]
  }

  eventhubs = [
  {
    name              = "test"
    partitions        = 5
    message_retention = 1
    consumers         = []
    keys = [
      {
        name   = "sender"
        listen = false
        send   = true
        manage = false
      },
      {
        name   = "receiver"
        listen = true
        send   = false
        manage = false
      }
    ]
  }
]

  public_network_access_enabled = true
  network_rulesets = []

  alerts_enabled = false
  action = []

  tags = var.tags
}

locals {
  event_hub = {
    connection = "${format("%s-evh-ns", local.project)}.servicebus.windows.net:9093"
  }
}

#tfsec:ignore:AZU023
resource "azurerm_key_vault_secret" "event_hub_keys" {
  for_each = module.event_hub.key_ids

  name         = format("evh-%s-%s", replace(each.key, ".", "-"), "key")
  value        = module.event_hub.keys[each.key].primary_key
  content_type = "text/plain"

  key_vault_id = module.key_vault.id
}

module "data_indexer" {
  source = "../../data_indexer"
  
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  name = format("%s-ti", local.project)

  plan_name = format("%s-plan-dataindexer", local.project)

  virtual_network_name = azurerm_virtual_network.vnet.name
  subnet_name = format("%s-snet", local.project)
  address_prefixes = var.subnet_cidr

  cdc_docker_image = "pagopa/change-data-capturer-ms"
  cdc_docker_image_tag = "0.0.7"

  data_ti_docker_image = "pagopa/data-ti-ms"
  data_ti_docker_image_tag = "0.0.1"

  json_config_path = "./config.json"

  private_endpoint_subnet_id = module.pendpoints_snet.id

  internal_storage_account_info = {
    account_kind                      = "StorageV2"
    account_tier                      = "Standard"
    account_replication_type          = "ZRS"
    access_tier                       = "Hot"
  }

  internal_storage = {
    private_dns_zone_blob_ids = [azurerm_private_dns_zone.privatelink_blob_core.id]
    private_dns_zone_queue_ids = []
    private_dns_zone_table_ids = []
  }
  evh_config = {
    name = format("%s-evh-ns", local.project)
    resource_group_name = azurerm_resource_group.rg.name
    topics = ["test"]
  }
  depends_on = [ module.event_hub ]
  tags = var.tags
}
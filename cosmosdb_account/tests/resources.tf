resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_sql" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_mongo" {
  name                = "privatelink.mongo.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_cassandra" {
  name                = "privatelink.cassandra.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_table" {
  name                = "privatelink.table.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_private_vnet" {
  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_sql.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mongo_private_vnet" {
  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_mongo.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false

  tags = var.tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "cassandra_private_vnet" {
  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_cassandra.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false

  tags = var.tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "table_core_private_vnet" {
  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_table.name
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
  service_endpoints                         = ["Microsoft.AzureCosmosDB"]
  private_endpoint_network_policies_enabled = false
}

module "cosmosdb_account" {
  source                           = "../../cosmosdb_account"
  name                             = "${local.project}-cosmosdb"
  location                         = var.location
  resource_group_name              = azurerm_resource_group.rg.name
  offer_type                       = var.offer_type
  kind                             = var.kind
  enable_free_tier                 = true
  enable_automatic_failover        = true
  domain                           = var.domain
  main_geo_location_location       = var.location
  main_geo_location_zone_redundant = var.main_geo_location_zone_redundant
  mongo_server_version             = var.mongo_server_version

  // For mongo,cassandra,table add "Enable Mongo","Enable Cassandra","Enable Table"
  capabilities = var.capabilities


  allowed_virtual_network_subnet_ids = [
    module.pendpoints_snet.id
  ]

  public_network_access_enabled = false

  // Virtual network settings
  is_virtual_network_filter_enabled = true



  private_endpoint_enabled = true
  subnet_id                = module.pendpoints_snet.id

  //to enable mongo,cassandra or table change azurerm_private_dns_zone.privatelink_sql to privatelink_mongo/cassandra/table
  private_dns_zone_sql_ids = [azurerm_private_dns_zone.privatelink_sql.id]


  tags = var.tags

}


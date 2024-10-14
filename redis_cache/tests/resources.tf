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

resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "${local.project}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.private_endpoint_subnet_cidr
}

resource "azurerm_private_dns_zone" "privatelink_redis_cache_windows_net" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_redis_cache_windows_net_vnet" {
  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_redis_cache_windows_net.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false

  tags = var.tags
}

#
# REDIS
#
module "redis_cache" {
  source = "../../redis_cache"

  name                = "${local.project}-redis"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  redis_version         = 6
  capacity              = 1
  enable_non_ssl_port   = false
  family                = "P"
  sku_name              = "Premium"
  enable_authentication = true
  zones                 = [1, 2, 3]

  private_endpoint = {
    enabled              = true
    virtual_network_id   = azurerm_virtual_network.vnet.id
    subnet_id            = azurerm_subnet.private_endpoint_subnet.id
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_redis_cache_windows_net.id]
  }

  tags = var.tags
}

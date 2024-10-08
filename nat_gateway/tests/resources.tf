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

# additional ips created externally of nat gw module
# optional
resource "azurerm_public_ip" "nat_ip_2" {
  name                = "${local.project}-natgw-pip-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1]
  tags                = var.tags
}

resource "azurerm_public_ip" "nat_ip_3" {
  name                = "${local.project}-natgw-pip-3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1]

  tags = var.tags
}

module "nat_gateway" {
  source = "../../nat_gateway"

  name                = "${local.project}-ng"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  zones = [1]

  public_ips_count = 2

  # optional
  additional_public_ip_ids = [azurerm_public_ip.nat_ip_2.id, azurerm_public_ip.nat_ip_3.id]

  tags = var.tags
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${local.project}-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet1_cidr

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet_nat_gateway_association" "subnet1" {
  nat_gateway_id = module.nat_gateway.id
  subnet_id      = azurerm_subnet.subnet1.id
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${local.project}-subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet2_cidr

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet_nat_gateway_association" "subnet2" {
  nat_gateway_id = module.nat_gateway.id
  subnet_id      = azurerm_subnet.subnet2.id
}

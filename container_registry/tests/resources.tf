resource "azurerm_resource_group" "vnet_acr_rg" {
  name     = "rg_fake_vnet_acr"
  location = var.location

  tags = var.tags
}

resource "azurerm_resource_group" "acr_rg" {
  name     = "rg_fake_acr"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet_acr" {
  name                = "vnet-fake-acr"
  resource_group_name = "vnet-fake-acr-rg"
  location            = var.location
  address_space       = ["10.3.200.0/16"]
}

module "private_endpoint_snet" {
  source                                    = "../../subnet"
  name                                      = "${local.project}-pe-snet"
  address_prefixes                          = ["10.3.200.0/24"]
  resource_group_name                       = azurerm_resource_group.vnet_acr_rg.name
  virtual_network_name                      = azurerm_virtual_network.vnet_acr.name
  private_endpoint_network_policies_enabled = true
}

## acr subnet
module "acr_snet" {
  source                                    = "../../subnet"
  name                                      = "${local.project}-acr-snet"
  address_prefixes                          = ["10.3.201.0/24"]
  resource_group_name                       = azurerm_resource_group.vnet_acr_rg.name
  virtual_network_name                      = azurerm_virtual_network.vnet_acr.name
  service_endpoints                         = ["Microsoft.acr"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_private_dns_zone" "external_zone" {
  name                = "${local.project}-private-dns-zone"
  resource_group_name = azurerm_resource_group.vnet_acr_rg.name
}

#--------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg_acr" {
  name     = "${local.project}-acr-rg"
  location = var.location

  tags = var.tags
}

module "__acr_private" {
  source              = "../../container_registry"
  name                = "acrprivatepremium"
  resource_group_name = azurerm_resource_group.rg_acr.name
  location            = azurerm_resource_group.rg_acr.location

  admin_enabled                 = false
  anonymous_pull_enabled        = false

  private_endpoint = {
    private_dns_zone_ids = [azurerm_private_dns_zone.external_zone.id]
    subnet_id            = module.acr_snet.id
    virtual_network_id   = azurerm_virtual_network.vnet_acr.id
  }

  network_rule_set = [{
    default_action  = "Allow"
    ip_rule         = []
    virtual_network = []
  }]

  tags = var.tags
}

module "__acr_public_dev" {
  source              = "../../container_registry"
  name                = "acrpublicdev"
  resource_group_name = azurerm_resource_group.rg_acr.name
  location            = azurerm_resource_group.rg_acr.location

  sku                           = "Standard"
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  zone_redundancy_enabled       = false
  public_network_access_enabled = true
  private_endpoint_enabled = false

  network_rule_set = [{
    default_action  = "Allow"
    ip_rule         = []
    virtual_network = []
  }]

  tags = var.tags
}

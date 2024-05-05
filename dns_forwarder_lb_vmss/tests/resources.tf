resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

module "subnet_dns_forwarder_lb" {
  source                                    = "../../subnet"

  name                 = "test-dns-forwarder-lb"
  address_prefixes     = ["10.1.0.200/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

module "subnet_dns_forwarder_vmss" {
  source                                    = "../../subnet"

  name                 = "test-dns-forwarder-vmss"
  address_prefixes     = ["10.1.0.201/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

#tfsec:ignore:azure-keyvault-no-purge
resource "azurerm_key_vault" "this" {
  name                     = "${var.prefix}-kv"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.location
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow" #tfsec:ignore:AZU020
  }
}

#
# DNS Forwarder
#
module "__dns_forwarder_lb_vmss_internal_subnet" {
  source = "../../dns_forwarder_lb_vmss"

  name                 = var.prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  subscription_id      = data.azurerm_subscription.current.subscription_id
  source_image_name    = var.source_image_name
  key_vault_id         = azurerm_key_vault.this.id

  use_internal_subnet_lb = true
  use_internal_subnet_vmss = true

  tags = var.tags
}


module "__dns_forwarder_lb_vmss_with_externals_subnet" {
  source = "../../dns_forwarder_lb_vmss"

  name                 = "dns-forwarder-with-subnet-externals"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name

  subnet_lb_id      = module.subnet_dns_forwarder_lb.id
  static_address_lb = cidrhost("10.1.0.200/24", 4)

  subnet_vmss_id    = module.subnet_dns_forwarder_vmss.id

  location          = var.location
  subscription_id   = data.azurerm_subscription.current.subscription_id
  source_image_name = var.source_image_name
  key_vault_id      = azurerm_key_vault.this.id
  tags              = var.tags
}

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

resource "azurerm_subnet" "apim_subnet" {
  name                 = "${local.project}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.apim_subnet_cidr
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.project}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "snet_nsg" {
  subnet_id                 = azurerm_subnet.apim_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "ip" {
  name                = "${local.project}-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "devio"

  tags = var.tags
}

resource "azurerm_application_insights" "ai" {
  name                = "${local.project}-ai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "other"

  tags = var.tags
}

module "apim_v2" {
  source = "../../api_management"

  subnet_id                 = azurerm_subnet.apim_subnet.id
  location                  = azurerm_resource_group.rg.location
  name                      = format("%s-apim-v2-api", local.project)
  resource_group_name       = azurerm_resource_group.rg.name
  publisher_name            = "test-apim"
  publisher_email           = "test-apim-email@pagopa.it"
  notification_sender_email = "test-apim-email@pagopa.it"
  sku_name                  = "Premium_2"
  virtual_network_type      = "Internal"
  zones                     = ["1", "2"]

  public_ip_address_id = azurerm_public_ip.ip.id

  redis_connection_string = null
  redis_cache_id          = null

  sign_up_enabled = false

  application_insights = {
    enabled             = true
    instrumentation_key = azurerm_application_insights.ai.instrumentation_key
  }

  lock_enable = false

  autoscale = {
    enabled                       = true
    default_instances             = 1
    minimum_instances             = 1
    maximum_instances             = 5
    scale_out_capacity_percentage = 50
    scale_out_time_window         = "PT10M"
    scale_out_value               = "2"
    scale_out_cooldown            = "PT45M"
    scale_in_capacity_percentage  = 30
    scale_in_time_window          = "PT30M"
    scale_in_value                = "1"
    scale_in_cooldown             = "PT30M"
  }

  alerts_enabled = false

  tags = var.tags
}
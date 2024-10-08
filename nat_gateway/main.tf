resource "azurerm_public_ip" "this" {
  count               = var.public_ips_count
  name                = format("%s-pip-%02d", var.name, count.index + 1)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones

  tags = var.tags
}

resource "azurerm_nat_gateway" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = var.sku_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.zones

  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count                = var.public_ips_count
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.this[count.index].id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_nat_gateway_public_ip_association" "additional_ips" {
  # used count instead of for_each to avoid
  # " The "for_each" set includes values derived from resource attributes that cannot be determined until apply, and so Terraform cannot determine the full set of keys that will identify the instances of this resource."
  count                = length(var.additional_public_ip_ids)
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = var.additional_public_ip_ids[count.index]
}

#
# Resource Group
#

resource "azurerm_resource_group" "this" {
  name     = "${local.project}-rg"
  location = var.location
  tags     = var.tags
}

#
# Virtual Network
#

resource "azurerm_virtual_network" "this" {
  name                = "${local.project}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
}

#
# Subnet
#

resource "azurerm_subnet" "this" {
  name                 = "${local.project}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.vms_subnet_cidr
}

#
# Load Balancer Public
#

module "lb_public" {
  source = "../../load_balancer"

  name                = "${local.project}-public-lb"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  lb_sku              = "Standard"

  frontend_name                          = "${local.project}-ip-public"
  frontend_private_ip_address_allocation = "Static"

  lb_backend_pools = [
    {
      name = "${var.prefix}-default-backend"
      ips = [
        {
          ip      = "10.0.0.11"
          vnet_id = azurerm_virtual_network.this.id
        }
      ]
    }
  ]

  lb_port = {
    https = {
      frontend_port     = "443"
      protocol          = "Tcp"
      backend_port      = "443"
      backend_pool_name = "${var.prefix}-default-backend"
      probe_name        = "${var.prefix}-https"
    }

  }

  lb_probe = {
    "${var.prefix}-https" = {
      protocol     = "Tcp"
      port         = "443"
      request_path = "/status"
    }
  }

  tags = var.tags
}

#
# Load Balancer Private
#

module "lb_private" {
  source = "../../load_balancer"

  name                = "${local.project}-private-lb"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  lb_sku              = "Standard"
  type                = "private"

  frontend_name               = "${local.project}-ip-private"
  frontend_private_ip_address = var.private_ip_address
  frontend_subnet_id          = azurerm_subnet.this.id

  lb_backend_pools = [
    {
      name = "${var.prefix}-default-backend"
      ips = [
        {
          ip      = "10.0.0.11"
          vnet_id = azurerm_virtual_network.this.id
        }
      ]
    }
  ]

  lb_port = {
    dns_udp = {
      frontend_port     = "53"
      protocol          = "Udp"
      backend_port      = "53"
      backend_pool_name = "${var.prefix}-default-backend"
      probe_name        = "${var.prefix}-dns"
    }
  }

  lb_probe = {
    "${var.prefix}-dns" = {
      protocol     = "Tcp"
      port         = "53"
      request_path = ""
    }
  }
  tags = var.tags
}

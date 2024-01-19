#
# Locals
#

locals {
  prefix                         = "${var.name}-dns-forwarder"
  frontend_private_ip_address_lb = var.static_address_lb != null ? var.static_address_lb : cidrhost(var.address_prefixes_lb, 4)

  subnet_vmss_id = var.subnet_vmss_id != null ? var.subnet_vmss_id : module.subnet_vmss[0].id
  subnet_lb_id   = var.subnet_lb_id != null ? var.subnet_lb_id : module.subnet_lb[0].id

}

#
# Subnet virtual machine scale set
#

module "subnet_vmss" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v7.47.0"
  count  = var.subnet_vmss_id != null ? 0 : 1

  name                 = "${local.prefix}-vmss-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.address_prefixes_vmss]
}

#
# Subnet load balancer
#

module "subnet_lb" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v7.47.0"
  count  = var.subnet_lb_id != null ? 0 : 1

  name                 = "${local.prefix}-lb-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.address_prefixes_lb]
}

#
# Network security group - virtual machine scale set
#

resource "azurerm_network_security_group" "vmss" {
  count = var.subnet_vmss_id != null ? 0 : 1

  name                = "${local.prefix}-vmss-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Inbound rule
  security_rule {
    name                       = "${local.prefix}-vmss-dns-tcp-rule"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "53"
    destination_port_range     = "53"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "168.63.129.16"
  }

  security_rule {
    name                       = "${local.prefix}-vmss-dns-udp-rule"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "53"
    destination_port_range     = "53"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "168.63.129.16"
  }

  security_rule {
    name                       = "${local.prefix}-vmss-deny-all-rule"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#
# Load balancer
#

module "lb" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//load_balancer?ref=v7.47.0"

  name                = "${local.prefix}-internal"
  resource_group_name = var.resource_group_name
  location            = var.location
  lb_sku              = "Standard"
  type                = "private"

  frontend_name                          = "${local.prefix}-ip-private"
  frontend_private_ip_address_allocation = "Static"
  frontend_private_ip_address            = local.frontend_private_ip_address_lb
  frontend_subnet_id                     = local.subnet_lb_id

  lb_probe = {
    "${local.prefix}" = {
      protocol     = "Tcp"
      port         = "53"
      request_path = ""
    }
  }

  lb_port = {
    "${local.prefix}-tcp" = {
      frontend_port     = "53"
      protocol          = "Tcp"
      backend_port      = "53"
      backend_pool_name = "${local.prefix}-vmss"
      probe_name        = local.prefix
    }
    "${local.prefix}-udp" = {
      frontend_port     = "53"
      protocol          = "Udp"
      backend_port      = "53"
      backend_pool_name = "${local.prefix}-vmss"
      probe_name        = local.prefix
    }
  }

  lb_backend_pools = [{
    name = "${local.prefix}-vmss"
    ips  = []
  }]
}

#
# Virtual machine scale set
#

module "vmss" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//vm_scale_set?ref=v7.47.0"

  name                                   = local.prefix
  resource_group_name                    = var.resource_group_name
  subnet_id                              = local.subnet_vmss_id
  subscription_id                        = var.subscription_id
  location                               = var.location
  source_image_name                      = var.source_image_name
  load_balancer_backend_address_pool_ids = module.lb.azurerm_lb_backend_address_pool_id
  authentication_type                    = "PASSWORD"
  admin_password                         = random_password.psw.result
  vm_sku                                 = var.vm_sku
  storage_sku                            = var.storage_sku
  tags                                   = var.tags
}

#
# Key vault - Password scale set
#

module "key_vault" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//key_vault?ref=v7.47.0"

  name                = local.prefix
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  tags                = var.tags
}

resource "random_password" "psw" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#tfsec:ignore:azure-keyvault-ensure-secret-expiry
resource "azurerm_key_vault_secret" "psw_vmss" {
  name         = local.prefix
  value        = random_password.psw.result
  content_type = "text/plain"
  key_vault_id = module.key_vault.id
}

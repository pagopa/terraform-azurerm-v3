locals {
  lb_backend_pool = { for pool in var.lb_backend_pools :
    pool.name => pool
  }
  lb_backend_pool_address = { for backend_address in flatten([for pool in var.lb_backend_pools :
    [for ip in pool.ips : {
      pool_name  = pool.name
      ip_address = ip.ip
      vnet_id    = ip.vnet_id
  }]]) : format("%s.%s", backend_address.pool_name, backend_address.ip_address) => backend_address }
}

resource "azurerm_public_ip" "this" {
  count = var.type == "public" ? 1 : 0

  name                = format("%s-lb-pip", var.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.allocation_method
  sku                 = var.pip_sku

  tags = var.tags
}

resource "azurerm_lb" "this" {
  name                = format("%s-lb", var.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.lb_sku
  tags                = var.tags

  frontend_ip_configuration {
    name                          = var.frontend_name
    public_ip_address_id          = var.type == "public" ? join("", azurerm_public_ip.this.*.id) : null
    subnet_id                     = var.frontend_subnet_id
    private_ip_address            = var.frontend_private_ip_address
    private_ip_address_allocation = var.frontend_private_ip_address_allocation
    private_ip_address_version    = "IPv4"
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  for_each = local.lb_backend_pool

  name            = format("%s-pool", each.key)
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_backend_address_pool_address" "this" {
  for_each = local.lb_backend_pool_address

  name                    = each.key
  backend_address_pool_id = azurerm_lb_backend_address_pool.this[each.value.pool_name].id
  virtual_network_id      = each.value.vnet_id
  ip_address              = each.value.ip_address
}

resource "azurerm_lb_probe" "this" {
  for_each = var.lb_probe

  name                = format("%s-probe", each.key)
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = each.value.protocol
  port                = each.value.port
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  request_path        = each.value.request_path
}

resource "azurerm_lb_rule" "this" {
  for_each = var.lb_port

  name                           = format("%s-rule", each.key)
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = var.frontend_name
  enable_floating_ip             = false
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[each.value.backend_pool_name].id]
  idle_timeout_in_minutes        = 5
  probe_id                       = each.value.probe_name != null ? azurerm_lb_probe.this[each.value.probe_name].id : null
}

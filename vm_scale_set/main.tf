#
# Locals
#

locals {
  source_image_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/images/${var.source_image_name}"
}

#
# SSH private key
#

resource "tls_private_key" "private_key" {
  count = var.authentication_type == "SSH" ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

#
# SSH public key
#

resource "azurerm_ssh_public_key" "public_key" {
  count = var.authentication_type == "SSH" ? 1 : 0

  name                = "${var.name}-admin-access-key"
  resource_group_name = var.resource_group_name
  location            = var.location
  public_key          = tls_private_key.private_key[0].public_key_openssh
}

#
# Virtual machine scale set
#

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = "${var.name}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_sku
  instances           = 1
  admin_username      = "adminuser"
  admin_password      = var.admin_password
  tags                = var.tags

  # only one of source_image_id and source_image_reference is allowed
  source_image_id = local.source_image_id

  os_disk {
    storage_account_type   = var.storage_sku
    caching                = "ReadWrite"
    disk_encryption_set_id = var.encryption_set_id
  }

  dynamic "admin_ssh_key" {
    for_each = var.authentication_type == "SSH" ? [true] : []
    content {
      username   = "adminuser"
      public_key = azurerm_ssh_public_key.public_key[0].public_key
    }
  }

  disable_password_authentication = var.authentication_type != "SSH" ? false : true

  overprovision = false

  network_interface {
    name    = "${var.name}-Nic"
    primary = true

    ip_configuration {
      name                                   = "${var.name}-IPc"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = var.load_balancer_backend_address_pool_ids
    }
  }
  platform_fault_domain_count = 1
  single_placement_group      = false
  upgrade_mode                = "Manual"

  lifecycle {
    ignore_changes = [
      # Ignore changes to these tags because they are generated by az devops.
      tags["__AzureDevOpsElasticPool"],
      tags["__AzureDevOpsElasticPoolTimeStamp"],
      instances
    ]
  }
}

#
# Virtual machine autoscale
#

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "${var.name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  profile {
    name = "${var.name}-autoscale-count"

    capacity {
      default = var.capacity_default_count
      maximum = var.capacity_maximum_count
      minimum = var.capacity_minimum_count
    }
  }
}
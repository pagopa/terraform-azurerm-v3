# DNS forwarder scale set vm

This module allows the creation of an dns forwarder (VM scale set), with a custom-built image.

The dns forwarder vm expose port 53 in TCP/UDP for azure vpn

## How to use

```hcl
module "dns_forwarder_backup_snet" {
  source               = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v8.8.0"
  count                = var.dns_forwarder_backup_is_enabled.uat || var.dns_forwarder_backup_is_enabled.prod ? 1 : 0
  name                 = "${local.project}-dns-forwarder-backup-snet"
  address_prefixes     = var.cidr_subnet_dns_forwarder_backup
  resource_group_name  = data.azurerm_resource_group.rg_vnet_core.name
  virtual_network_name = data.azurerm_virtual_network.vnet_core.name
}

# with default image
module "dns_forwarder_backup_vmss_li" {

  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//dns_forwarder_scale_set_vm?ref=v8.8.0"
  count               = var.dns_forwarder_backup_is_enabled.uat || var.dns_forwarder_backup_is_enabled.prod ? 1 : 0
  name                = local.dns_forwarder_backup_name
  resource_group_name = data.azurerm_resource_group.rg_vnet_core.name
  subnet_id           = module.dns_forwarder_backup_snet[0].id
  subscription_name   = data.azurerm_subscription.current.display_name
  subscription_id     = data.azurerm_subscription.current.subscription_id
  location            = var.location
  source_image_name   = "${local.product}-dns-forwarder-ubuntu2204-image-v4"

  tags = var.tags
}

```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.97.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_monitor_autoscale_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_ssh_public_key.this_public_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ssh_public_key) | resource |
| [tls_private_key.this_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created. will be stored in the raw state as plain-text | `string` | `null` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | (Required) Type of authentication to use with the VM. Defaults to password for Windows and SSH public key for Linux. all enables both ssh and password authentication. | `string` | `"SSH"` | no |
| <a name="input_capacity_default_count"></a> [capacity\_default\_count](#input\_capacity\_default\_count) | (Required) The number of instances that are available for scaling if metrics are not available for evaluation. The default is only used if the current instance count is lower than the default. Valid values are between 0 and 1000 | `number` | `1` | no |
| <a name="input_capacity_maximum_count"></a> [capacity\_maximum\_count](#input\_capacity\_maximum\_count) | (Required) The maximum number of instances for this resource. Valid values are between 0 and 1000 | `number` | `1` | no |
| <a name="input_capacity_minimum_count"></a> [capacity\_minimum\_count](#input\_capacity\_minimum\_count) | (Required) The minimum number of instances for this resource. Valid values are between 0 and 1000 | `number` | `1` | no |
| <a name="input_encryption_set_id"></a> [encryption\_set\_id](#input\_encryption\_set\_id) | (Optional) An existing encryption set | `string` | `null` | no |
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | (Optional) A source\_image\_reference block as defined below. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | <pre>{<br>  "offer": "0001-com-ubuntu-server-jammy",<br>  "publisher": "Canonical",<br>  "sku": "22_04-lts-gen2",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the Linux Virtual Machine Scale Set. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group in which the Linux Virtual Machine Scale Set should be exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_source_image_name"></a> [source\_image\_name](#input\_source\_image\_name) | (Optional) The name of an Image which each Virtual Machine in this Scale Set should be based on. It must be stored in the same subscription & resource group of this resource | `string` | n/a | yes |
| <a name="input_storage_sku"></a> [storage\_sku](#input\_storage\_sku) | (Optional) The SKU of the storage account with which to persist VM. Use a singular sku that would be applied across all disks, or specify individual disks. Usage: [--storage-sku SKU \| --storage-sku ID=SKU ID=SKU ID=SKU...], where each ID is os or a 0-indexed lun. Allowed values: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS, UltraSSD\_LRS, Premium\_ZRS, StandardSSD\_ZRS. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) An existing subnet ID | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) Azure subscription id | `string` | n/a | yes |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | (Required) Azure subscription name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | (Optional) Size of VMs in the scale set. Default to Standard\_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info. | `string` | `"Standard_B1s"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Azure devops agent 

This module allows the creation of an Azure DevOps agent (VM scale set), using either a standard OS image or a custom-built image.

## How to use

By default, this module creates a ScaleSet using Ubuntu22.04, without using os disk encryption, and providing SSH access using a generated ssh key

```hcl
resource "azurerm_resource_group" "azdo_rg" {
  count    = var.enable_azdoa ? 1 : 0
  name     = local.azuredevops_rg_name
  location = var.location

  tags = var.tags
}

# with custom image (previously built. check the module `azure_devops_agent_custom_image` for more details)
module "module "azdoa_vmss_li" {" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=v8.8.0"
  count               = var.enable_azdoa ? 1 : 0
  name                = "${local.azuredevops_agent_vm_name}"
  resource_group_name = azurerm_resource_group.azdo_rg[0].name
  subnet_id           = module.azdoa_snet[0].id
  subscription_name   = data.azurerm_subscription.current.display_name
  subscription_id     = data.azurerm_subscription.current.id
  location            = var.location
  source_image_name   = "my-image-name" # the image must be stored in the same subscription/resource group of this resource
  image_type          = "custom" # enables usage of "source_image_name" 

  tags = var.tags
}

# with default image
module "module "azdoa_vmss_li" {" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=v8.8.0"
  count               = var.enable_azdoa ? 1 : 0
  name                = "${local.azuredevops_agent_vm_name}"
  resource_group_name = azurerm_resource_group.azdo_rg[0].name
  subnet_id           = module.azdoa_snet[0].id
  subscription_name   = data.azurerm_subscription.current.display_name
  subscription_id     = data.azurerm_subscription.current.id
  location            = var.location

  tags = var.tags
}

# with standard image
module "module "azdoa_vmss_li" {" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=v8.8.0"
  count               = var.enable_azdoa ? 1 : 0
  name                = "${local.azuredevops_agent_vm_name}"
  resource_group_name = azurerm_resource_group.azdo_rg[0].name
  subnet_id           = module.azdoa_snet[0].id
  subscription_name   = data.azurerm_subscription.current.display_name
  subscription_id     = data.azurerm_subscription.current.id
  location            = var.location
  image_reference     = {
    publisher         = "Canonical"
    offer             = "0001-com-ubuntu-server-jammy"
    sku               = "22_04-lts-gen2"
    version           = "latest"
  }

  tags = var.tags
}



```

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>3.30 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_ssh_public_key.this_public_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ssh_public_key) | resource |
| [tls_private_key.this_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created. will be stored in the raw state as plain-text | `string` | `null` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | (Required) Type of authentication to use with the VM. Defaults to password for Windows and SSH public key for Linux. all enables both ssh and password authentication. | `string` | `"SSH"` | no |
| <a name="input_encryption_set_id"></a> [encryption\_set\_id](#input\_encryption\_set\_id) | (Optional) An existing encryption set | `string` | `null` | no |
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | (Optional) A source\_image\_reference block as defined below. | <pre>object({<br/>    publisher = string<br/>    offer     = string<br/>    sku       = string<br/>    version   = string<br/>  })</pre> | <pre>{<br/>  "offer": "0001-com-ubuntu-server-jammy",<br/>  "publisher": "Canonical",<br/>  "sku": "22_04-lts-gen2",<br/>  "version": "latest"<br/>}</pre> | no |
| <a name="input_image_resource_group_name"></a> [image\_resource\_group\_name](#input\_image\_resource\_group\_name) | (Optional) Resource group name where to find the vm image used for azdo vms. If not defined, 'resource\_group\_name' will be used | `string` | `null` | no |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | (Required) Defines the source image to be used, whether 'custom' or 'standard'. `custom` requires `source_image_name` to be defined, `standard` requires `image_reference` | `string` | `"custom"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the Linux Virtual Machine Scale Set. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group in which the Linux Virtual Machine Scale Set should be exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_source_image_name"></a> [source\_image\_name](#input\_source\_image\_name) | (Optional) The name of an Image which each Virtual Machine in this Scale Set should be based on. It must be stored in the same subscription & resource group of this resource | `string` | n/a | yes |
| <a name="input_storage_sku"></a> [storage\_sku](#input\_storage\_sku) | (Optional) The SKU of the storage account with which to persist VM. Use a singular sku that would be applied across all disks, or specify individual disks. Usage: [--storage-sku SKU \| --storage-sku ID=SKU ID=SKU ID=SKU...], where each ID is os or a 0-indexed lun. Allowed values: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS, UltraSSD\_LRS, Premium\_ZRS, StandardSSD\_ZRS. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) An existing subnet ID | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) Azure subscription id | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(any)` | `{}` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | (Optional) Size of VMs in the scale set. Default to Standard\_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info. | `string` | `"Standard_B2ms"` | no |
| <a name="input_vmss_instances"></a> [vmss\_instances](#input\_vmss\_instances) | (Optional) The number of Virtual Machines in the Scale Set. Defaults to 0. | `number` | `"0"` | no |
| <a name="input_zone_balance"></a> [zone\_balance](#input\_zone\_balance) | (Optional) If true forces the even distribution of instances across all the configured zones ('zones' variable) | `bool` | `false` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | (Optional) List of AZ on which the scale set will distribute its instances | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scale_set_id"></a> [scale\_set\_id](#output\_scale\_set\_id) | n/a |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_ssh_public_key.this_public_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ssh_public_key) | resource |
| [tls_private_key.this_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created. will be stored in the raw state as plain-text | `string` | `null` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | (Required) Type of authentication to use with the VM. Defaults to password for Windows and SSH public key for Linux. all enables both ssh and password authentication. | `string` | `"SSH"` | no |
| <a name="input_encryption_set_id"></a> [encryption\_set\_id](#input\_encryption\_set\_id) | (Optional) An existing encryption set | `string` | `null` | no |
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | (Optional) A source\_image\_reference block as defined below. | <pre>object({<br/>    publisher = string<br/>    offer     = string<br/>    sku       = string<br/>    version   = string<br/>  })</pre> | <pre>{<br/>  "offer": "0001-com-ubuntu-server-jammy",<br/>  "publisher": "Canonical",<br/>  "sku": "22_04-lts-gen2",<br/>  "version": "latest"<br/>}</pre> | no |
| <a name="input_image_resource_group_name"></a> [image\_resource\_group\_name](#input\_image\_resource\_group\_name) | (Optional) Resource group name where to find the vm image used for azdo vms. If not defined, 'resource\_group\_name' will be used | `string` | `null` | no |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | (Required) Defines the source image to be used, whether 'custom' or 'standard'. `custom` requires `source_image_name` to be defined, `standard` requires `image_reference` | `string` | `"custom"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the Linux Virtual Machine Scale Set. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group in which the Linux Virtual Machine Scale Set should be exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_source_image_name"></a> [source\_image\_name](#input\_source\_image\_name) | (Optional) The name of an Image which each Virtual Machine in this Scale Set should be based on. It must be stored in the same subscription & resource group of this resource | `string` | n/a | yes |
| <a name="input_storage_sku"></a> [storage\_sku](#input\_storage\_sku) | (Optional) The SKU of the storage account with which to persist VM. Use a singular sku that would be applied across all disks, or specify individual disks. Usage: [--storage-sku SKU \| --storage-sku ID=SKU ID=SKU ID=SKU...], where each ID is os or a 0-indexed lun. Allowed values: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS, UltraSSD\_LRS, Premium\_ZRS, StandardSSD\_ZRS. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) An existing subnet ID | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) Azure subscription id | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(any)` | `{}` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | (Optional) Size of VMs in the scale set. Default to Standard\_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info. | `string` | `"Standard_B2ms"` | no |
| <a name="input_vmss_instances"></a> [vmss\_instances](#input\_vmss\_instances) | (Optional) The number of Virtual Machines in the Scale Set. Defaults to 0. | `number` | `"0"` | no |
| <a name="input_zone_balance"></a> [zone\_balance](#input\_zone\_balance) | (Optional) If true forces the even distribution of instances across all the configured zones ('zones' variable) | `bool` | `false` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | (Optional) List of AZ on which the scale set will distribute its instances | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scale_set_id"></a> [scale\_set\_id](#output\_scale\_set\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

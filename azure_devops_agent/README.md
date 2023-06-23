# Azure devops agent 

This module allows the creation of an Azure DevOps agent (VM scale set), using either a standard OS image or a custom-built image.
It also gives the possibility to add a custom script extension to the VMs, either one of the provided in this module or a custom extension provided externally

## How to use

By default, this module creates a ScaleSet using Ubuntu22.04, without using os disk encryption, and providing SSH access using a generated ssh key

additional parameters allow you to create VM SS using:

- standard image (provided by az marketplace)
- custom image (previously built and stored on the same resource group of the SS)
- shared image (previously built and stored on a Shared Image Gallery, even in a different subscription, if enabled)

with:

- no extensions (the SS will start with the VM image, plain and simple)
- with provided extension (the VM will run the extension provided at startup)
- with custom extension (the VM will run the extension you wrote at startup)

```hcl
resource "azurerm_resource_group" "azdo_rg" {
  count    = var.enable_azdoa ? 1 : 0
  name     = local.azuredevops_rg_name
  location = var.location

  tags = var.tags
}

# with custom image (previously built. check the module `azure_devops_agent_custom_image` for more details)
module "azdoa_vmss_li"  {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=<version>"
  count               = var.enable_azdoa ? 1 : 0
  name                = "${local.azuredevops_agent_vm_name}"
  resource_group_name = azurerm_resource_group.azdo_rg[0].name
  subnet_id           = module.azdoa_snet[0].id
  subscription_name   = data.azurerm_subscription.current.display_name
  subscription_id     = data.azurerm_subscription.current.id
  location            = var.location
  image_name          = var.azdoa_image_name
  image_version       = var.azdoa_image_version # the image must be stored in the same subscription/resource group of this resource
  image_type          = "managed" # enables usage of "image_name" and "image_version" 

  tags = var.tags
}

# with default image
module "azdoa_vmss_li" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=<version>"
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
module "azdoa_vmss_li" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=<version>"
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


# with provided extension
module "azdoa_vmss_li" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=<version>"
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

  extension_name = "install_requirements" # matches the folder name in "extensions" directory 

  tags = var.tags
}

# with custom extension
module "azdoa_vmss_li" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=39c5e91"
  count               = var.enable_azdoa ? 1 : 0
  name                = local.azuredevops_agent_vm_name
  resource_group_name = azurerm_resource_group.azdo_rg[0].name
  subnet_id           = module.azdoa_snet[0].id
  subscription_name   = data.azurerm_subscription.current.display_name
  subscription_id     = data.azurerm_subscription.current.subscription_id
  location            = var.location
  image_name          = var.azdoa_image_name
  image_version       = var.azdoa_image_version
  image_type          = "managed"

  extension_name = "tcpflow"
  custom_extension_path = "${path.module}/extensions/tcpflow/script-config.json"

  tags = var.tags
}


# with shared image
module "azdoa_vmss_li" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent?ref=39c5e91"
  count               = var.enable_azdoa ? 1 : 0
  name                = local.azuredevops_agent_vm_name
  resource_group_name = azurerm_resource_group.azdo_rg[0].name
  subnet_id           = module.azdoa_snet[0].id
  subscription_name   = data.azurerm_subscription.current.display_name
  subscription_id     = data.azurerm_subscription.current.subscription_id
  location            = var.location
  image_name          = var.azdoa_image_name
  image_version       = var.azdoa_image_version
  image_type          = "shared"

  shared_subscription_id = var.shared_subscription_id
  shared_resource_group_name = var.shared_rg_name
  shared_gallery_name = var.shared_gallery_name

  tags = var.tags
}

```

## Extensions

Here is the list of the provided extensions

| Name | Description                                                                                   |
|------|-----------------------------------------------------------------------------------------------|
| install_requirements| Installs all the required packages for an azure devops agent, such as az-cli, docker, helm... |



### How to define a custom extension

If you want to provide a custom extension, you need to define you own extension script and extension config file (like the ones defined here, in the `extensions` folder).
There is no limitation in the file naming, just be sure con configure the correct path in the `json` file. 
Then you have to provide it to this module using both the `extension_name` and `custom_extension_path` properties, as shown in the example above. 

In this case, the extension name can be arbitrary, since it does not need to match with a folder in this module

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.53.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.53.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_ssh_public_key.this_public_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ssh_public_key) | resource |
| [azurerm_virtual_machine_scale_set_extension.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [tls_private_key.this_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created. will be stored in the raw state as plain-text | `string` | `null` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | (Required) Type of authentication to use with the VM. Defaults to password for Windows and SSH public key for Linux. all enables both ssh and password authentication. | `string` | `"SSH"` | no |
| <a name="input_custom_extension_path"></a> [custom\_extension\_path](#input\_custom\_extension\_path) | (Optional) if 'extension\_name' is not in the provided extensions, defines the path where to find the extension settings | `string` | `null` | no |
| <a name="input_encryption_set_id"></a> [encryption\_set\_id](#input\_encryption\_set\_id) | (Optional) An existing encryption set | `string` | `null` | no |
| <a name="input_extension_name"></a> [extension\_name](#input\_extension\_name) | (Optional) name of the extension to add to the VM. Either one of the provided (must match the folder name) or a custom extension (arbitrary name) | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | (Optional) The image name to be used, valid for 'shared' or 'managed' image\_type | `string` | `null` | no |
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | (Optional) A source\_image\_reference block as defined below. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | <pre>{<br>  "offer": "0001-com-ubuntu-server-jammy",<br>  "publisher": "Canonical",<br>  "sku": "22_04-lts-gen2",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | (Required) Defines the source image to be used, whether 'managed' or 'standard'. `managed` and `shared` requires `image_name` and `image_version` to be defined, `standard` requires `image_reference` | `string` | `"managed"` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | (Optional) The image version to be used, valid for 'shared' or 'managed' image\_type | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the Linux Virtual Machine Scale Set. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group in which the Linux Virtual Machine Scale Set should be exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_shared_gallery_name"></a> [shared\_gallery\_name](#input\_shared\_gallery\_name) | (Optional) The shared image gallery (AZ compute gallery) name the shared image is stored | `string` | `null` | no |
| <a name="input_shared_resource_group_name"></a> [shared\_resource\_group\_name](#input\_shared\_resource\_group\_name) | (Optional) The resource group name where the shared image is stored | `string` | `null` | no |
| <a name="input_shared_subscription_id"></a> [shared\_subscription\_id](#input\_shared\_subscription\_id) | (Optional) The subscription id where the shared image is stored | `string` | `null` | no |
| <a name="input_storage_sku"></a> [storage\_sku](#input\_storage\_sku) | (Optional) The SKU of the storage account with which to persist VM. Use a singular sku that would be applied across all disks, or specify individual disks. Usage: [--storage-sku SKU \| --storage-sku ID=SKU ID=SKU ID=SKU...], where each ID is os or a 0-indexed lun. Allowed values: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS, UltraSSD\_LRS, Premium\_ZRS, StandardSSD\_ZRS. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) An existing subnet ID | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) Azure subscription id | `string` | n/a | yes |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | (Required) Azure subscription name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | (Optional) Size of VMs in the scale set. Default to Standard\_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info. | `string` | `"Standard_B1s"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

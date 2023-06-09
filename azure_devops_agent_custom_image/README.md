# Azure devops agent custom image
This module allow to create a custom linux image and store it in the provided resource group

## Prerequisite

Install packer [here](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)


## How to use

This module must be runned manually to create the image that will be later used

This module uses interactive authentication to access your target subscription. While running terraform be sure to check for the authentication code and link to enable packer to access your subscription
you will be prompted with a message like the following

```
module.azdoa_custom_image.null_resource.build_packer_image (local-exec): ==> azure-arm.ubuntu: Microsoft Azure: To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code CTJELKS6T to authenticate.
```

you will be asked for auth access **two times** at the beginning of the build


Example:
```hcl
data "azurerm_resource_group" "resource_group" {
  name = "${local.project}-azdoa-rg"
}


# managed image
module "azdoa_custom_image" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent_custom_image?ref=<version>"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = var.location
  image_name          = "my_image_name"
  image_version       = "v1"
  subscription_id     = data.azurerm_subscription.current.subscription_id

  image_type = "managed" #default
}

# shared image
module "azdoa_custom_image" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//azure_devops_agent_custom_image?ref=<version>"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = var.location
  image_name          = "azdo-agent-custom-image"
  image_version       = "1.0.0"
  subscription_id     = data.azurerm_subscription.current.subscription_id

  image_type = "shared" #default


  tags = var.tags
}

```



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
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_shared_image.shared_image_placeholder](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) | resource |
| [azurerm_shared_image_gallery.image_gallery](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery) | resource |
| [null_resource.build_packer_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_image_offer"></a> [base\_image\_offer](#input\_base\_image\_offer) | (Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference | `string` | `"0001-com-ubuntu-server-jammy"` | no |
| <a name="input_base_image_publisher"></a> [base\_image\_publisher](#input\_base\_image\_publisher) | (Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference | `string` | `"Canonical"` | no |
| <a name="input_base_image_sku"></a> [base\_image\_sku](#input\_base\_image\_sku) | (Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference | `string` | `"22_04-lts-gen2"` | no |
| <a name="input_base_image_version"></a> [base\_image\_version](#input\_base\_image\_version) | (Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference | `string` | `"latest"` | no |
| <a name="input_force_replacement"></a> [force\_replacement](#input\_force\_replacement) | (Optional) Wheather if the image should be deleted and recreated even if already existing | `bool` | `false` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | (Required) name assigned to the generated image. Note that the pair <image\_name, image\_version> must be unique and not already existing | `string` | n/a | yes |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | (Required) Defines the type of the image to be created: shared or managed | `string` | `"shared"` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | (Required) Version assigned to the generated image. Note that the pair <image\_name, image\_version> must be unique and not already existing | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group in which the custom image will be created | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) Azure subscription id | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | (Optional) Size of VMs in the scale set. Default to Standard\_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info. | `string` | `"Standard_B1s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_image_id"></a> [custom\_image\_id](#output\_custom\_image\_id) | Azure id of the custom image you just created |
| <a name="output_custom_image_name"></a> [custom\_image\_name](#output\_custom\_image\_name) | Name of the created image |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# dns forwarder vm image

This module allow to create a custom linux image and setup core dns to use as dns forwarder

## Prerequisite (client side)

Install packer [here](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)

## How it works

to make coredns work, we chose to use docker compose with a custom image (pagopa) taken from this repository: <https://github.com/pagopa/azure-core-dns> which contains coredns configured to work with the azure dns server, in this way it is easier to keep the coredns updated coredns.

> The dns forwarder image expose port 53 in TCP/UDP for azure vpn

## How to debug

Unfortunately the packer run within terraform does not show logs as it contains sensitive values.

To allow debugging, the script has been made to generate a log file in the path `/tmp/packer-dnsforwarder.log` so that it can be viewed and analyzed later

## How to use

This module must be runned manually to create the image that will be later used

The final image is built in a temporary resource group, named after the build resource group name passed in input, combined with a random code. This resource group, for technical limitations, is kept in the subscription and deleted upon the next image build (the image name/version has to change in order to trigger the deletion)

Once done, you can simply pick up the built image name from the log, and configure it to be used as base image for your vm or scale set

**NB:** the build may fail because it's not able to locate some package; you simply need to try it again

Example:

```hcl
module "dns_forwarder_image" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//dns_forwarder_vm_image?ref=v8.8.0"
  resource_group_name = data.azurerm_resource_group.rg_vnet_core.name
  location            = var.location
  image_name          = "${local.product}-dns-forwarder-ubuntu2204-image"
  image_version       = "v1"
  subscription_id     = data.azurerm_subscription.current.subscription_id
  prefix              = "pagopa-u"

  tags = var.tags
}

```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.47 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.97 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.build_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [null_resource.build_packer_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.rg_randomizer](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.target_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_image_offer"></a> [base\_image\_offer](#input\_base\_image\_offer) | (Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference | `string` | `"0001-com-ubuntu-server-jammy"` | no |
| <a name="input_base_image_publisher"></a> [base\_image\_publisher](#input\_base\_image\_publisher) | (Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference | `string` | `"Canonical"` | no |
| <a name="input_base_image_sku"></a> [base\_image\_sku](#input\_base\_image\_sku) | (Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference | `string` | `"22_04-lts-gen2"` | no |
| <a name="input_base_image_version"></a> [base\_image\_version](#input\_base\_image\_version) | (Optional) - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set#source_image_reference | `string` | `"latest"` | no |
| <a name="input_build_rg_name"></a> [build\_rg\_name](#input\_build\_rg\_name) | (Optional) Packer build temporary resource group name | `string` | `"tmp-packer-dnsforwarder-image-build"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | (Required) name assigned to the generated image. Note that the pair <image\_name, image\_version> must be unique and not already existing | `string` | n/a | yes |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | (Required) Version assigned to the generated image. Note that the pair <image\_name, image\_version> must be unique and not already existing | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) prefix used in resource creation | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group in which the custom image will be created | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) Azure subscription id | `string` | n/a | yes |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | (Optional) Size of VMs in the scale set. Default to Standard\_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info. | `string` | `"Standard_B2ms"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_image_id"></a> [custom\_image\_id](#output\_custom\_image\_id) | Azure id of the custom image you just created |
| <a name="output_custom_image_name"></a> [custom\_image\_name](#output\_custom\_image\_name) | Name of the created image |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

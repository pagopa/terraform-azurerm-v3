# Test for Azure module

Terraform template to test the module.

You need the access to DevOpsLab Subscription or change backend.ini value.

`resources.tf` file contains all resources to test.

## How to use it

- ./terraform.sh plan
- ./terraform.sh apply
- ./terraform.sh destroy
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.97.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module___acr_private"></a> [\_\_acr\_private](#module\_\_\_acr\_private) | ../../container_registry | n/a |
| <a name="module___acr_public_dev"></a> [\_\_acr\_public\_dev](#module\_\_\_acr\_public\_dev) | ../../container_registry | n/a |
| <a name="module_acr_snet"></a> [acr\_snet](#module\_acr\_snet) | ../../subnet | n/a |
| <a name="module_private_endpoint_snet"></a> [private\_endpoint\_snet](#module\_private\_endpoint\_snet) | ../../subnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.external_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_resource_group.acr_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.rg_acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.vnet_acr_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.vnet_acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Resorce location | `string` | `"italynorth"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"azrmtest"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Azurerm test tags | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform",<br/>  "Source": "https://github.com/pagopa/terraform-azurerm-v3"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

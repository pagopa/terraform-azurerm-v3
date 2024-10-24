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
| <a name="module_event_hub_complete"></a> [event\_hub\_complete](#module\_event\_hub\_complete) | ../../eventhub | n/a |
| <a name="module_event_hub_core_network"></a> [event\_hub\_core\_network](#module\_event\_hub\_core\_network) | ../../eventhub | n/a |
| <a name="module_event_hub_core_only"></a> [event\_hub\_core\_only](#module\_event\_hub\_core\_only) | ../../eventhub | n/a |
| <a name="module_eventhub_snet"></a> [eventhub\_snet](#module\_eventhub\_snet) | ../../subnet | n/a |
| <a name="module_private_endpoint_snet"></a> [private\_endpoint\_snet](#module\_private\_endpoint\_snet) | ../../subnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.external_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_resource_group.eventhub_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.rg_eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.vnet_eventhub_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Resorce location | `string` | `"italynorth"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"azrmtest"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Azurerm test tags | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform",<br/>  "Source": "https://github.com/pagopa/terraform-azurerm-v3"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

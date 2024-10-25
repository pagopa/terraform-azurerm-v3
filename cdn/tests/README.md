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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.94.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cdn"></a> [cdn](#module\_cdn) | ../../cdn | n/a |
| <a name="module_cdn_different_location"></a> [cdn\_different\_location](#module\_cdn\_different\_location) | ../../cdn | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_log_analytics_workspace.log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Resorce location | `string` | `"italynorth"` | no |
| <a name="input_location_cdn"></a> [location\_cdn](#input\_location\_cdn) | Resorce location CDN | `string` | `"westeurope"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"azrmtest"` | no |
| <a name="input_subnet1_cidr"></a> [subnet1\_cidr](#input\_subnet1\_cidr) | n/a | `list(string)` | <pre>[<br/>  "10.0.1.0/26"<br/>]</pre> | no |
| <a name="input_subnet2_cidr"></a> [subnet2\_cidr](#input\_subnet2\_cidr) | n/a | `list(string)` | <pre>[<br/>  "10.0.2.0/26"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Azurerm test tags | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform",<br/>  "Source": "https://github.com/pagopa/terraform-azurerm-v3"<br/>}</pre> | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | n/a | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

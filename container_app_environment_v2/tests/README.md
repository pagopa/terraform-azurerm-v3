# tests

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.94.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_app_environment"></a> [container\_app\_environment](#module\_container\_app\_environment) | ../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_law_name"></a> [law\_name](#input\_law\_name) | n/a | `string` | `"azrmtest-law"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"westeurope"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | `"azrmtest"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | `"azrmtest-rg"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform",<br/>  "Source": "https://github.com/pagopa/terraform-azurerm-v3"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cae_id"></a> [cae\_id](#output\_cae\_id) | n/a |
| <a name="output_random_id"></a> [random\_id](#output\_random\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

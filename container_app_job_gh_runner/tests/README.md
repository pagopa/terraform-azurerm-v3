# tests

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.94.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_app_job_runner"></a> [container\_app\_job\_runner](#module\_container\_app\_job\_runner) | ../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.container_app_environment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_log_analytics_workspace.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.rg_runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_job"></a> [job](#input\_job) | Container App job properties | <pre>object({<br/>    name                 = optional(string)<br/>    repo_owner           = optional(string)<br/>    repo                 = optional(string)<br/>    polling_interval     = optional(number)<br/>    scale_max_executions = optional(number)<br/>  })</pre> | <pre>{<br/>  "name": "azurermv3",<br/>  "polling_interval": 30,<br/>  "repo": "terraform-azurerm-v3",<br/>  "repo_owner": "pagopa",<br/>  "scale_max_executions": 5<br/>}</pre> | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | KeyVault properties | <pre>object({<br/>    resource_group_name = string<br/>    name                = string<br/>    secret_name         = string<br/>  })</pre> | <pre>{<br/>  "name": "azrmtest-keyvault",<br/>  "resource_group_name": "azrmtest-keyvault-rg",<br/>  "secret_name": "gh-pat"<br/>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"westeurope"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"azrmte"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform",<br/>  "Source": "https://github.com/pagopa/terraform-azurerm-v3"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_name"></a> [ca\_name](#output\_ca\_name) | Container App job name |
| <a name="output_cae_name"></a> [cae\_name](#output\_cae\_name) | Container App Environment name |
| <a name="output_random_id"></a> [random\_id](#output\_random\_id) | n/a |
| <a name="output_subnet_cidr"></a> [subnet\_cidr](#output\_subnet\_cidr) | Subnet CIDR blocks |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | Subnet name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

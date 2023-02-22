# Azure function app slot

Module that allows the creation of an Azure function app slot.

## How to use it

Use the example Terraform template, saved in `terraform-azurerm-v3/function_app_slot/tests`, to test this module.

## How to migrate from ```azurerm_function_app_slot``` to ```azurerm_linux_function_app_slot```

## Migration from v2

Output for resource `azurerm_function_app_host_keys` changed

See [Generic resorce migration](../docs/MIGRATION_GUIDE_GENERIC_RESOURCES.md)

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.44.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.30.0, <= 3.44.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_slot_virtual_network_swift_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_slot_virtual_network_swift_connection) | resource |
| [azurerm_linux_function_app_slot.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app_slot) | resource |
| [azurerm_function_app_host_keys.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/function_app_host_keys) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | Ip from wich is allowed to call the function. An empty list means from everywhere. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnets"></a> [allowed\_subnets](#input\_allowed\_subnets) | List of subnet ids which are allowed to call the function. An empty list means from each subnet. | `list(string)` | `[]` | no |
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | (Optional) Should the app be loaded at all times? Defaults to null. | `bool` | `null` | no |
| <a name="input_app_service_plan_id"></a> [app\_service\_plan\_id](#input\_app\_service\_plan\_id) | The app service plan id to associate to the function. | `string` | `null` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | n/a | `map(any)` | `{}` | no |
| <a name="input_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#input\_application\_insights\_instrumentation\_key) | n/a | `string` | n/a | yes |
| <a name="input_auto_swap_slot_name"></a> [auto\_swap\_slot\_name](#input\_auto\_swap\_slot\_name) | The name of the slot to automatically swap to during deployment | `string` | `null` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | n/a | <pre>object({<br>    allowed_origins = list(string)<br>  })</pre> | `null` | no |
| <a name="input_export_keys"></a> [export\_keys](#input\_export\_keys) | n/a | `bool` | `false` | no |
| <a name="input_function_app_id"></a> [function\_app\_id](#input\_function\_app\_id) | Id of the function app. (The production slot) | `string` | n/a | yes |
| <a name="input_function_app_name"></a> [function\_app\_name](#input\_function\_app\_name) | Name of the function app. (The production slot) | `string` | n/a | yes |
| <a name="input_health_check_maxpingfailures"></a> [health\_check\_maxpingfailures](#input\_health\_check\_maxpingfailures) | n/a | `number` | `10` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Path which will be checked for this function app health. | `string` | `null` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | (Required) n the Function App only be accessed via HTTPS? Defaults to true. | `bool` | `true` | no |
| <a name="input_internal_storage_connection_string"></a> [internal\_storage\_connection\_string](#input\_internal\_storage\_connection\_string) | Storage account connection string for durable functions. Null in case of standard function | `string` | `null` | no |
| <a name="input_linux_fx_version"></a> [linux\_fx\_version](#input\_linux\_fx\_version) | (Required) Linux App Framework and version for the AppService, e.g. DOCKER\|(golang:latest). Use null if function app is on windows | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | (Optional) A string indicating the Operating System type for this function app. This value will be linux for Linux derivatives, or an empty string for Windows (default). When set to linux you must also set azurerm\_app\_service\_plan arguments as kind = Linux and reserved = true | `string` | `null` | no |
| <a name="input_pre_warmed_instance_count"></a> [pre\_warmed\_instance\_count](#input\_pre\_warmed\_instance\_count) | n/a | `number` | `1` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | n/a | `string` | `"~3"` | no |
| <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key) | Access key of the sorege account used by the function. | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Storage account in use by the functio. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet the app service will be associated to (the subnet must have a service\_delegation configured for Microsoft.Web/serverFarms) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_use_32_bit_worker_process"></a> [use\_32\_bit\_worker\_process](#input\_use\_32\_bit\_worker\_process) | (Optional) Should the Function App run in 32 bit mode, rather than 64 bit mode? Defaults to false. | `bool` | `false` | no |
| <a name="input_vnet_integration"></a> [vnet\_integration](#input\_vnet\_integration) | (optional) Enable vnet integration. Wheter it's true the subnet\_id should not be null. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | n/a |
| <a name="output_default_key"></a> [default\_key](#output\_default\_key) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_master_key"></a> [master\_key](#output\_master\_key) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_possible_outbound_ip_addresses"></a> [possible\_outbound\_ip\_addresses](#output\_possible\_outbound\_ip\_addresses) | n/a |
| <a name="output_primary_key"></a> [primary\_key](#output\_primary\_key) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

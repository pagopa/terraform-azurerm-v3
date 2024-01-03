# App service

This module allow the creation of an app service.
In terraform output you can get the the app service's name and id.

## How to use it
Use the example Terraform template, saved in `./tests`, to test this module and get some advices.

## How to migrate from `azurerm_app_service` to `azurerm_linux_web_app`
The script tests/migrate.sh will remove and import the deprecated resources as new ones.
You need to know the resource old and new names.
```
e.g.
# app_service resources to migrate
cd tests
./migrate.sh module.web_app_service_docker.azurerm_app_service.this module.web_app_service_docker.azurerm_linux_web_app.this
./migrate.sh azurerm_app_service_plan.app_docker azurerm_service_plan.app_docker

# app_service_slot resource to migrate
./migrate.sh module.web_app_service_slot_docker.azurerm_app_service_slot.this module.web_app_service_slot_docker.azurerm_linux_web_app_slot.this
```

## Note about migrating from `azurerm_app_service` to `azurerm_linux_web_app`

Since the resource `azurerm_app_service` has been deprecated in version 3.0 of the AzureRM provider, the newer `azurerm_linux_web_app` resource is used in this module, thus the following variables have been:

removed:
- os_type
- app_service_plan_info/sku_tier
- linux_fx_version
- app_service_plan_id

replaced:
- min_tls_version -> minimum_tls_version
- client_cert_enabled -> client_certificate_enabled

## How to configure the Linux framework

Don't use `linux_fx_version` anymore.
Now you need to specify **only** one variable of the following list:
- docker - (Optional) One or more docker blocks as defined below.
- dotnet_version - (Optional) The version of .NET to use. Possible values include 3.1, 6.0 and 7.0.
- use_dotnet_isolated_runtime - (Optional) Should the DotNet process use an isolated runtime. Defaults to false.
- java_version - (Optional) The Version of Java to use. Supported versions include 8, 11 & 17 (In-Preview).
- node_version - (Optional) The version of Node to run. Possible values include 12, 14, 16 and 18.
- python_version - (Optional) The version of Python to run. Possible values are 3.10, 3.9, 3.8 and 3.7.
- powershell_core_version - (Optional) The version of PowerShell Core to run. Possible values are 7, and 7.2.
- use_custom_runtime - (Optional) Should the Linux Function App use a custom runtime?

Of course, the values listed above may change in the future, so please check which ones are still valid.

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.39.0, <= 3.84.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_virtual_network_swift_connection.app_service_virtual_network_swift_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_linux_web_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | (Optional) List of ips allowed to call the appserver endpoint. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnets"></a> [allowed\_subnets](#input\_allowed\_subnets) | (Optional) List of subnet allowed to call the appserver endpoint. | `list(string)` | `[]` | no |
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | (Optional) Should the app be loaded at all times? Defaults to false. | `bool` | `false` | no |
| <a name="input_app_command_line"></a> [app\_command\_line](#input\_app\_command\_line) | (Optional) App command line to launch, e.g. /sbin/myserver -b 0.0.0.0. | `string` | `null` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | n/a | `map(string)` | `{}` | no |
| <a name="input_client_affinity_enabled"></a> [client\_affinity\_enabled](#input\_client\_affinity\_enabled) | (Optional) Should the App Service send session affinity cookies, which route client requests in the same session to the same instance? Defaults to false. | `bool` | `false` | no |
| <a name="input_client_cert_enabled"></a> [client\_cert\_enabled](#input\_client\_cert\_enabled) | (Optional) Does the App Service require client certificates for incoming requests? Defaults to false. | `bool` | `false` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Framework choice | `string` | `null` | no |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | n/a | `string` | `null` | no |
| <a name="input_dotnet_version"></a> [dotnet\_version](#input\_dotnet\_version) | n/a | `string` | `null` | no |
| <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state) | (Optional) Enable FTPS connection ( Default: Disabled ) | `string` | `"Disabled"` | no |
| <a name="input_go_version"></a> [go\_version](#input\_go\_version) | n/a | `string` | `null` | no |
| <a name="input_health_check_maxpingfailures"></a> [health\_check\_maxpingfailures](#input\_health\_check\_maxpingfailures) | Max ping failures allowed | `number` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | (Optional) The health check path to be pinged by App Service. | `string` | `null` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | (Optional) Can the App Service only be accessed via HTTPS? Defaults to true. | `bool` | `true` | no |
| <a name="input_java_server"></a> [java\_server](#input\_java\_server) | n/a | `string` | `null` | no |
| <a name="input_java_server_version"></a> [java\_server\_version](#input\_java\_server\_version) | n/a | `string` | `null` | no |
| <a name="input_java_version"></a> [java\_version](#input\_java\_version) | n/a | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Specifies the name of the App Service. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_node_version"></a> [node\_version](#input\_node\_version) | n/a | `string` | `null` | no |
| <a name="input_php_version"></a> [php\_version](#input\_php\_version) | n/a | `string` | `null` | no |
| <a name="input_plan_id"></a> [plan\_id](#input\_plan\_id) | (Optional only if plan\_type=internal) Specifies the external app service plan id. | `string` | `null` | no |
| <a name="input_plan_kind"></a> [plan\_kind](#input\_plan\_kind) | (Optional) The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan). Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_plan_maximum_elastic_worker_count"></a> [plan\_maximum\_elastic\_worker\_count](#input\_plan\_maximum\_elastic\_worker\_count) | (Optional) The maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan. | `number` | `null` | no |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | (Optional) Specifies the name of the App Service Plan component. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_plan_per_site_scaling"></a> [plan\_per\_site\_scaling](#input\_plan\_per\_site\_scaling) | (Optional) Can Apps assigned to this App Service Plan be scaled independently? If set to false apps assigned to this plan will scale to all instances of the plan. Defaults to false. | `bool` | `false` | no |
| <a name="input_plan_type"></a> [plan\_type](#input\_plan\_type) | (Required) Specifies if app service plan is external or internal | `string` | `"internal"` | no |
| <a name="input_python_version"></a> [python\_version](#input\_python\_version) | n/a | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the App Service and App Service Plan. | `string` | n/a | yes |
| <a name="input_ruby_version"></a> [ruby\_version](#input\_ruby\_version) | n/a | `string` | `null` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | (Required) The SKU for the plan. | `string` | `null` | no |
| <a name="input_sticky_settings"></a> [sticky\_settings](#input\_sticky\_settings) | (Optional) A list of app\_setting names that the Linux Function App will not swap between Slots when a swap operation is triggered | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Optional) Subnet id wether you want to integrate the app service to a subnet. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_use_32_bit_worker_process"></a> [use\_32\_bit\_worker\_process](#input\_use\_32\_bit\_worker\_process) | (Optional) Should the Function App run in 32 bit mode, rather than 64 bit mode? Defaults to false. | `bool` | `false` | no |
| <a name="input_vnet_integration"></a> [vnet\_integration](#input\_vnet\_integration) | (optional) enable vnet integration. Wheter it's true the subnet\_id should not be null. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id) | n/a |
| <a name="output_default_site_hostname"></a> [default\_site\_hostname](#output\_default\_site\_hostname) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_plan_id"></a> [plan\_id](#output\_plan\_id) | n/a |
| <a name="output_plan_name"></a> [plan\_name](#output\_plan\_name) | n/a |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

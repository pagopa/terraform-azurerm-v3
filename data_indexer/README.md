# Data indexer

This module allow the creation of an app service.
In terraform output you can get the the app service's name and id.

## How to use it
Use the example Terraform template, saved in `./tests`, to test this module and get some advices.

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.39.0, <= 3.84.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_internal_storage_account"></a> [internal\_storage\_account](#module\_internal\_storage\_account) | ../storage_account | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_virtual_network_swift_connection.cdc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_app_service_virtual_network_swift_connection.data_ti](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_linux_web_app.cdc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_linux_web_app.data_ti](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_monitor_autoscale_setting.appservice_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_private_endpoint.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.evh_listener](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.evh_sender](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_eventhub.evh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefixes"></a> [address\_prefixes](#input\_address\_prefixes) | (Optional) The address prefixes to use for the subnet. (e.g. ['10.1.137.0/24']) | `list(string)` | `[]` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | (Optional) List of ips allowed to call the appserver endpoint. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnets"></a> [allowed\_subnets](#input\_allowed\_subnets) | (Optional) List of subnet allowed to call the appserver endpoint. | `list(string)` | `[]` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | n/a | `map(string)` | `{}` | no |
| <a name="input_autoscale_default"></a> [autoscale\_default](#input\_autoscale\_default) | The number of instances that are available for scaling if metrics are not available for evaluation. | `number` | `5` | no |
| <a name="input_autoscale_maximum"></a> [autoscale\_maximum](#input\_autoscale\_maximum) | The maximum number of instances for this resource. | `number` | `20` | no |
| <a name="input_autoscale_minimum"></a> [autoscale\_minimum](#input\_autoscale\_minimum) | The minimum number of instances for this resource. | `number` | `1` | no |
| <a name="input_cdc_docker_image"></a> [cdc\_docker\_image](#input\_cdc\_docker\_image) | n/a | `string` | `"pagopa/change-data-capturer-ms"` | no |
| <a name="input_cdc_docker_image_tag"></a> [cdc\_docker\_image\_tag](#input\_cdc\_docker\_image\_tag) | n/a | `string` | `"0.1.0@sha256:94379d99d78062e89353b45d6b463cd7bf80e24869b7d2d1a8b7cbf316fd07e4"` | no |
| <a name="input_data_ti_docker_image"></a> [data\_ti\_docker\_image](#input\_data\_ti\_docker\_image) | n/a | `string` | `"pagopa/data-ti-ms"` | no |
| <a name="input_data_ti_docker_image_tag"></a> [data\_ti\_docker\_image\_tag](#input\_data\_ti\_docker\_image\_tag) | n/a | `string` | `"0.1.0@sha256:dc7b8cee0aa1e22658f61a0d5d19be44202f83f0533f35de2ef0eb87697cdb94"` | no |
| <a name="input_docker_registry_url"></a> [docker\_registry\_url](#input\_docker\_registry\_url) | n/a | `string` | `"http://ghcr.io/"` | no |
| <a name="input_evh_config"></a> [evh\_config](#input\_evh\_config) | The Internal Event Hubs (topics) configuration | <pre>object({<br>    name                = string<br>    resource_group_name = string<br>    topics              = set(string)<br>  })</pre> | n/a | yes |
| <a name="input_health_check_maxpingfailures"></a> [health\_check\_maxpingfailures](#input\_health\_check\_maxpingfailures) | Max ping failures allowed | `number` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | (Optional) The health check path to be pinged by App Service. | `string` | `null` | no |
| <a name="input_internal_storage"></a> [internal\_storage](#input\_internal\_storage) | n/a | <pre>object({<br>    private_dns_zone_blob_ids  = list(string)<br>    private_dns_zone_queue_ids = list(string)<br>    private_dns_zone_table_ids = list(string)<br><br>  })</pre> | <pre>{<br>  "private_dns_zone_blob_ids": [],<br>  "private_dns_zone_queue_ids": [],<br>  "private_dns_zone_table_ids": []<br>}</pre> | no |
| <a name="input_internal_storage_account_info"></a> [internal\_storage\_account\_info](#input\_internal\_storage\_account\_info) | n/a | <pre>object({<br>    account_kind             = string # Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to Storage.<br>    account_tier             = string # Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.<br>    account_replication_type = string # Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.<br>    access_tier              = string # Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot.<br>  })</pre> | <pre>{<br>  "access_tier": "Hot",<br>  "account_kind": "StorageV2",<br>  "account_replication_type": "GZRS",<br>  "account_tier": "Standard"<br>}</pre> | no |
| <a name="input_json_config_path"></a> [json\_config\_path](#input\_json\_config\_path) | The Internal JSON configuration file path | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `"northitaly"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Specifies the name of the App Service. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_plan_id"></a> [plan\_id](#input\_plan\_id) | (Optional only if plan\_type=internal) Specifies the external app service plan id. | `string` | `null` | no |
| <a name="input_plan_kind"></a> [plan\_kind](#input\_plan\_kind) | (Optional) The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan). Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_plan_maximum_elastic_worker_count"></a> [plan\_maximum\_elastic\_worker\_count](#input\_plan\_maximum\_elastic\_worker\_count) | (Optional) The maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan. | `number` | `null` | no |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | (Optional) Specifies the name of the App Service Plan component. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_plan_per_site_scaling"></a> [plan\_per\_site\_scaling](#input\_plan\_per\_site\_scaling) | (Optional) Can Apps assigned to this App Service Plan be scaled independently? If set to false apps assigned to this plan will scale to all instances of the plan. Defaults to false. | `bool` | `false` | no |
| <a name="input_plan_type"></a> [plan\_type](#input\_plan\_type) | (Required) Specifies if app service plan is external or internal | `string` | `"internal"` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | (Required) The ID of the private endpoints subnet to use | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the App Service and App Service Plan. | `string` | n/a | yes |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | (Optional) The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web. | `list(string)` | <pre>[<br>  "Microsoft.Web",<br>  "Microsoft.AzureCosmosDB",<br>  "Microsoft.Storage",<br>  "Microsoft.Sql",<br>  "Microsoft.EventHub"<br>]</pre> | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | (Required) The SKU for the plan. | `string` | `"P0v3"` | no |
| <a name="input_sticky_settings"></a> [sticky\_settings](#input\_sticky\_settings) | (Optional) A list of app\_setting names that the Linux Function App will not swap between Slots when a swap operation is triggered | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Optional) Subnet id wether you want to integrate the app service to a subnet. | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | n/a | `string` | n/a | yes |
| <a name="input_vnet_integration"></a> [vnet\_integration](#input\_vnet\_integration) | (optional) enable vnet integration. Wheter it's true the subnet\_id should not be null. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

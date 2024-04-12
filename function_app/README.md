# Azure function app

Module that allows the creation of an Azure function app.
It creates a resource group named `azrmtest<6 hexnumbers>-rg` and every resource into it is named `azrmtest<6 hexnumbers>-*`.
In terraform output you can get the resource group name.

## Architecture

![architecture](./docs/module-arch.drawio.png)

## How to use it
Use the example Terraform template, saved in `terraform-azurerm-v3/function_app/tests`, to see a working example of this module.

**Note** that the runtime properties are mutually exclusive

```hcl
module "function_app" {
  [...]
  # the following properties are mutually exclusive
  docker = {
    image_name = ""
    image_tag = ""
    registry_password = ""
    registry_url = ""
    registry_username = ""
  }
  python_version = ""
  dotnet_version = ""
  use_dotnet_isolated_runtime = true|false
  java_version = ""
  node_version = ""
  python_version = ""
  powershell_core_version = ""
  use_custom_runtime = ""
  # end of mutually exclusive properties
  [...]
}
```

### Sticky values

Sometimes it happens that Terraform fails to modify certain variables even after running `terraform apply`, and keeps proposing the changes repeatedly. 
In this case, the variables to be ignored should be included in the `sticky_app_setting_names` variable. 

E.g. 
```hcl
  sticky_app_setting_names = [
    "DOCKER_REGISTRY_SERVER_PASSWORD",
    "DOCKER_REGISTRY_SERVER_URL",
    "DOCKER_REGISTRY_SERVER_USERNAME"
  ]
```
### Some examples

**Docker**
```hcl
module "authorizer_function_app" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//function_app?ref=v6.6.0"

  resource_group_name = data.azurerm_resource_group.shared_rg.name
  name                = "${local.project}-authorizer-fn"
  location            = var.location
  health_check_path   = "info"
  subnet_id           = module.authorizer_functions_snet.id
  runtime_version     = "~4"

  system_identity_enabled = true

  always_on                                = var.authorizer_function_always_on
  application_insights_instrumentation_key = data.azurerm_application_insights.application_insights.instrumentation_key
  docker = {
    image_name        = "pagopa${var.env_short}commonacr.azurecr.io/pagopaplatformauthorizer"
    image_tag         = var.authorizer_functions_app_image_tag
    registry_password = data.azurerm_container_registry.acr.admin_password
    registry_url      = "https://${data.azurerm_container_registry.acr.login_server}"
    registry_username = data.azurerm_container_registry.acr.admin_username
  }

  sticky_connection_string_names = ["COSMOS_CONN_STRING", "COSMOS_CONNection_STRING"]
  client_certificate_mode        = "Optional"


  cors = {
    allowed_origins = []
  }

  app_service_plan_name = "${local.project}-plan-authorizer-fn"
  app_service_plan_info = {
    kind                         = var.authorizer_functions_app_sku.kind
    sku_size                     = var.authorizer_functions_app_sku.sku_size
    maximum_elastic_worker_count = 1
    worker_count                 = 1
    zone_balancing_enabled       = false
  }

  storage_account_name = replace(format("%s-auth-st", local.project), "-", "")

  app_settings = {
    linux_fx_version                    = "JAVA|11"
    FUNCTIONS_WORKER_RUNTIME            = "java"
    FUNCTIONS_WORKER_PROCESS_COUNT      = 4
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = true

    DOCKER_REGISTRY_SERVER_URL      = "https://${data.azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = data.azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = data.azurerm_container_registry.acr.admin_password

    COSMOS_CONN_STRING         = data.azurerm_key_vault_secret.authorizer_cosmos_connection_string.value
    REFRESH_CONFIGURATION_PATH = data.azurerm_key_vault_secret.authorizer_refresh_configuration_url.value
  }

  allowed_subnets = [data.azurerm_subnet.apim_vnet.id]

  allowed_ips = []

  tags = var.tags
}
```

**Python** 

from `tests/resources.tf`

```hcl
module "function_app" {
  source = "../../function_app"

  name                = "${local.project}-fn"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  health_check_path   = "/api/v1/info"
  python_version      = "3.9"
  runtime_version     = "~4"

  always_on                                = true
  application_insights_instrumentation_key = azurerm_application_insights.ai.instrumentation_key

  app_settings = merge(
    local.function_app.app_settings_common, {}
  )

  subnet_id = azurerm_subnet.function_app_subnet.id

  allowed_subnets = [
    azurerm_subnet.function_app_subnet.id,
  ]

  app_service_plan_info = {
    kind     = "Linux"
    sku_size = "P1v3"
    # The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU.
    maximum_elastic_worker_count = 0
    # The number of Workers (instances) to be allocated.
    worker_count = 2
    # Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created.
    zone_balancing_enabled = true
  }

  tags = var.tags
}
```

## Redundancy
To deploy it in multiple Availability Zones in the region you need to set the following variables:
- `zone_balancing_enabled = true`
- `worker_count = <2+>`

Furthermore, you need to set the region (es. `location = northeurope`).

:warning: **At the moment (May 04, 2023), in `westeurope` is not possible to deploy service plans in multiple Availability Zones!**


## How to migrate `from azurerm_function_app` to `azurerm_linux_function_app`
The following [script](https://github.com/pagopa/eng-common-scripts/blob/main/azure/migrate-resource.sh) will remove and import the deprecated resources as new ones.

Be sure to modify the function `removeAndImport` calls (found at the end of the script) according to your needs


## Note about migrating from ```azurerm_function_app``` to ```azurerm_linux_function_app```

Since the resource `azurerm_function_app` has been deprecated in version 3.0 of the AzureRM provider, the newer `azurerm_linux_function_app` resource is used in this module, thus the following variables have been removed since they are not used anymore:
- os_type
- app_service_plan_info/sku_tier
- linux_fx_version

## How to configure the Linux framework

You need to specify **only** one variable of the following list:
- docker - (Optional) One or more docker blocks as defined below.
- dotnet_version - (Optional) The version of .NET to use. Possible values include 3.1, 6.0 and 7.0.
- use_dotnet_isolated_runtime - (Optional) Should the DotNet process use an isolated runtime. Defaults to false.
- java_version - (Optional) The Version of Java to use. Supported versions include 8, 11 & 17 (In-Preview).
- node_version - (Optional) The version of Node to run. Possible values include 12, 14, 16 and 18.
- python_version - (Optional) The version of Python to run. Possible values are 3.10, 3.9, 3.8 and 3.7.
- powershell_core_version - (Optional) The version of PowerShell Core to run. Possible values are 7, and 7.2.
- use_custom_runtime - (Optional) Should the Linux Function App use a custom runtime?

Of course, the values listed above may change in the future, so please check which ones are current.

## Migration from v2

Output for resource `azurerm_function_app_host_keys` changed

See [Generic resource migration](../.docs/MIGRATION_GUIDE_GENERIC_RESOURCES.md)

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.76.0, <= 3.97.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | github.com/pagopa/terraform-azurerm-v3.git//storage_account | v7.76.0 |
| <a name="module_storage_account_durable_function"></a> [storage\_account\_durable\_function](#module\_storage\_account\_durable\_function) | github.com/pagopa/terraform-azurerm-v3.git//storage_account | v7.76.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_virtual_network_swift_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_linux_function_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_monitor_metric_alert.function_app_health_check](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_private_endpoint.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_container.internal_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.internal_deleteafterdays](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_storage_queue.internal_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_function_app_host_keys.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/function_app_host_keys) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br>    {<br>      action_group_id    = string<br>      webhook_properties = map(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | The IP Address used for this IP Restriction in CIDR notation | `list(string)` | `[]` | no |
| <a name="input_allowed_subnets"></a> [allowed\_subnets](#input\_allowed\_subnets) | List of subnet ids, The Virtual Network Subnet ID used for this IP Restriction. | `list(string)` | `[]` | no |
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | (Optional) Should the app be loaded at all times? Defaults to null. | `bool` | `null` | no |
| <a name="input_app_service_logs"></a> [app\_service\_logs](#input\_app\_service\_logs) | disk\_quota\_mb - (Optional) The amount of disk space to use for logs. Valid values are between 25 and 100. Defaults to 35. retention\_period\_days - (Optional) The retention period for logs in days. Valid values are between 0 and 99999.(never delete). | <pre>object({<br>    disk_quota_mb         = number<br>    retention_period_days = number<br>  })</pre> | `null` | no |
| <a name="input_app_service_plan_id"></a> [app\_service\_plan\_id](#input\_app\_service\_plan\_id) | The external app service plan id to associate to the function. If null a new plan is created, use app\_service\_plan\_info to configure it. | `string` | `null` | no |
| <a name="input_app_service_plan_info"></a> [app\_service\_plan\_info](#input\_app\_service\_plan\_info) | Allows to configurate the internal service plan | <pre>object({<br>    kind                         = string # The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan).<br>    sku_size                     = string # Specifies the plan's instance size.<br>    maximum_elastic_worker_count = number # The maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan.<br>    worker_count                 = number # The number of Workers (instances) to be allocated.<br>    zone_balancing_enabled       = bool   # Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created.<br>  })</pre> | <pre>{<br>  "kind": "Linux",<br>  "maximum_elastic_worker_count": 0,<br>  "sku_size": "P1v3",<br>  "worker_count": 0,<br>  "zone_balancing_enabled": false<br>}</pre> | no |
| <a name="input_app_service_plan_name"></a> [app\_service\_plan\_name](#input\_app\_service\_plan\_name) | Name of the app service plan. If null it will be 'computed' | `string` | `null` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | (Optional) A map of key-value pairs for App Settings and custom values. | `map(any)` | `{}` | no |
| <a name="input_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#input\_application\_insights\_instrumentation\_key) | Application insights instrumentation key | `string` | n/a | yes |
| <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled) | Should the function app use Client Certificates | `bool` | `false` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | (Optional) The mode of the Function App's client certificates requirement for incoming requests. Possible values are Required, Optional, and OptionalInteractiveUser. | `string` | `"Optional"` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | n/a | <pre>object({<br>    allowed_origins = list(string) # A list of origins which should be able to make cross-origin calls. * can be used to allow all calls.<br>  })</pre> | `null` | no |
| <a name="input_docker"></a> [docker](#input\_docker) | ##################### Framework choice ##################### | `any` | `{}` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Specifies the domain of the Function App. | `string` | `null` | no |
| <a name="input_dotnet_version"></a> [dotnet\_version](#input\_dotnet\_version) | n/a | `string` | `null` | no |
| <a name="input_enable_healthcheck"></a> [enable\_healthcheck](#input\_enable\_healthcheck) | Enable the healthcheck alert. Default is true | `bool` | `true` | no |
| <a name="input_export_keys"></a> [export\_keys](#input\_export\_keys) | n/a | `bool` | `false` | no |
| <a name="input_health_check_maxpingfailures"></a> [health\_check\_maxpingfailures](#input\_health\_check\_maxpingfailures) | Max ping failures allowed | `number` | `10` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Path which will be checked for this function app health. | `string` | `null` | no |
| <a name="input_healthcheck_threshold"></a> [healthcheck\_threshold](#input\_healthcheck\_threshold) | The healthcheck threshold. If metric average is under this value, the alert will be triggered. Default is 50 | `number` | `50` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | (Required) Can the Function App only be accessed via HTTPS?. Defaults true | `bool` | `true` | no |
| <a name="input_internal_storage"></a> [internal\_storage](#input\_internal\_storage) | n/a | <pre>object({<br>    enable                     = bool<br>    private_endpoint_subnet_id = string<br>    private_dns_zone_blob_ids  = list(string)<br>    private_dns_zone_queue_ids = list(string)<br>    private_dns_zone_table_ids = list(string)<br>    queues                     = list(string) # Queues names<br>    containers                 = list(string) # Containers names<br>    blobs_retention_days       = number<br>  })</pre> | <pre>{<br>  "blobs_retention_days": 1,<br>  "containers": [],<br>  "enable": false,<br>  "private_dns_zone_blob_ids": [],<br>  "private_dns_zone_queue_ids": [],<br>  "private_dns_zone_table_ids": [],<br>  "private_endpoint_subnet_id": "dummy",<br>  "queues": []<br>}</pre> | no |
| <a name="input_internal_storage_account_info"></a> [internal\_storage\_account\_info](#input\_internal\_storage\_account\_info) | n/a | <pre>object({<br>    account_kind                      = string # Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to Storage.<br>    account_tier                      = string # Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.<br>    account_replication_type          = string # Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.<br>    access_tier                       = string # Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot.<br>    advanced_threat_protection_enable = bool<br>    use_legacy_defender_version       = bool<br>    public_network_access_enabled     = bool<br>  })</pre> | `null` | no |
| <a name="input_ip_restriction_default_action"></a> [ip\_restriction\_default\_action](#input\_ip\_restriction\_default\_action) | (Optional) The Default action for traffic that does not match any ip\_restriction rule. possible values include 'Allow' and 'Deny'. If not set, it will be set to Allow if no ip restriction rules have been configured. | `string` | `null` | no |
| <a name="input_java_version"></a> [java\_version](#input\_java\_version) | n/a | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Specifies the name of the Function App. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_node_version"></a> [node\_version](#input\_node\_version) | n/a | `string` | `null` | no |
| <a name="input_powershell_core_version"></a> [powershell\_core\_version](#input\_powershell\_core\_version) | n/a | `string` | `null` | no |
| <a name="input_pre_warmed_instance_count"></a> [pre\_warmed\_instance\_count](#input\_pre\_warmed\_instance\_count) | The number of pre-warmed instances for this function app. Only affects apps on the Premium plan. | `number` | `1` | no |
| <a name="input_python_version"></a> [python\_version](#input\_python\_version) | n/a | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | The runtime version associated with the Function App. Version ~3 is required for Linux Function Apps. | `string` | `"~3"` | no |
| <a name="input_sticky_app_setting_names"></a> [sticky\_app\_setting\_names](#input\_sticky\_app\_setting\_names) | (Optional) A list of app\_setting names that the Linux Function App will not swap between Slots when a swap operation is triggered | `list(string)` | `[]` | no |
| <a name="input_sticky_connection_string_names"></a> [sticky\_connection\_string\_names](#input\_sticky\_connection\_string\_names) | (Optional) A list of connection string names that the Linux Function App will not swap between Slots when a swap operation is triggered | `list(string)` | `null` | no |
| <a name="input_storage_account_durable_name"></a> [storage\_account\_durable\_name](#input\_storage\_account\_durable\_name) | Storage account name only used by the durable function. If null it will be 'computed' | `string` | `null` | no |
| <a name="input_storage_account_info"></a> [storage\_account\_info](#input\_storage\_account\_info) | n/a | <pre>object({<br>    account_kind                      = string # Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to Storage.<br>    account_tier                      = string # Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.<br>    account_replication_type          = string # Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.<br>    access_tier                       = string # Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot.<br>    advanced_threat_protection_enable = bool<br>    use_legacy_defender_version       = bool<br>    public_network_access_enabled     = bool<br>  })</pre> | <pre>{<br>  "access_tier": "Hot",<br>  "account_kind": "StorageV2",<br>  "account_replication_type": "ZRS",<br>  "account_tier": "Standard",<br>  "advanced_threat_protection_enable": true,<br>  "public_network_access_enabled": false,<br>  "use_legacy_defender_version": true<br>}</pre> | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Storage account name. If null it will be 'computed' | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet the app service will be associated to (the subnet must have a service\_delegation configured for Microsoft.Web/serverFarms) | `string` | n/a | yes |
| <a name="input_system_identity_enabled"></a> [system\_identity\_enabled](#input\_system\_identity\_enabled) | Enable the System Identity and create relative Service Principal. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_use_32_bit_worker_process"></a> [use\_32\_bit\_worker\_process](#input\_use\_32\_bit\_worker\_process) | (Optional) Should the Function App run in 32 bit mode, rather than 64 bit mode? Defaults to false. | `bool` | `false` | no |
| <a name="input_use_custom_runtime"></a> [use\_custom\_runtime](#input\_use\_custom\_runtime) | n/a | `string` | `null` | no |
| <a name="input_use_dotnet_isolated_runtime"></a> [use\_dotnet\_isolated\_runtime](#input\_use\_dotnet\_isolated\_runtime) | n/a | `string` | `null` | no |
| <a name="input_vnet_integration"></a> [vnet\_integration](#input\_vnet\_integration) | (optional) Enable vnet integration. Wheter it's true the subnet\_id should not be null. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | n/a |
| <a name="output_app_service_plan_name"></a> [app\_service\_plan\_name](#output\_app\_service\_plan\_name) | n/a |
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | n/a |
| <a name="output_default_key"></a> [default\_key](#output\_default\_key) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_master_key"></a> [master\_key](#output\_master\_key) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_possible_outbound_ip_addresses"></a> [possible\_outbound\_ip\_addresses](#output\_possible\_outbound\_ip\_addresses) | n/a |
| <a name="output_primary_key"></a> [primary\_key](#output\_primary\_key) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | n/a |
| <a name="output_storage_account_internal_function"></a> [storage\_account\_internal\_function](#output\_storage\_account\_internal\_function) | Storage account used by the function for internal operations. |
| <a name="output_storage_account_internal_function_name"></a> [storage\_account\_internal\_function\_name](#output\_storage\_account\_internal\_function\_name) | Storage account used by the function for internal operations. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
| <a name="output_system_identity_principal"></a> [system\_identity\_principal](#output\_system\_identity\_principal) | Service Principal of the System Identity generated by Azure. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Monitoring Function

This module creates the required resources used by a container app job which, based on a scheduling defined by a cron expression, monitors the configured apis and certificates, exporting the metrics to application insight

details on the function can be found [here](https://github.com/pagopa/azure-synthetic-monitoring)

## How to use it

This is the minimum configuration required to use the monitoring function

Field `monitoring_configuration_encoded` is required to be passed as a string, using  `jsonencode(<json content>)` function or `file(<json_file_path>)` function
details on its content can be found [here](https://github.com/pagopa/azure-synthetic-monitoring)

### Alert configuration

In addition to the properties defined above, `alertConfiguration` can be specified to customize the alert associated to the monitored api

That's an example of the properties that can be specified, containing the default values that will be used if not specified
```json
{
    "enabled" : true, # (Optional) enables the alert
    "severity" : 0,   # (Optional) The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4
    "frequency" : "PT1M", # (Optional) The evaluation frequency of this Metric Alert, represented in ISO 8601 duration format. Possible values are PT1M, PT5M, PT15M, PT30M and PT1H
    "threshold" : 100, # (Optional) The criteria threshold value that activates the alert
    "operator" : "LessThan" # (Optional) The criteria operator. Possible values are Equals, GreaterThan, GreaterThanOrEqual, LessThan and LessThanOrEqual
    "aggregation": "Average" # (Required) The statistic that runs over the metric values. Possible values are Average, Count, Minimum, Maximum and Total.
}
```

This module creates a table storage to save the provided monitoring configuration; if the private endpoint is enabled it requires the `table` private dns zone group

```hcl

module "synthetic_monitoring_subnet" {
  source               = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v7.39.0"
  name                 = "${var.prefix}-synthetic-monitoring-snet"
  address_prefixes     = ["10.1.182.0/23"]
  resource_group_name  = "dvopla-d-vnet-rg"
  virtual_network_name = data.azurerm_virtual_network.vnet.name

  private_endpoint_network_policies_enabled = true

  service_endpoints = [
    "Microsoft.Storage"
  ]
}

# try to re-use already existing container app environment to save address space in your vnet.
# each environment requires a dedicated subnet /23
resource "azurerm_container_app_environment" "container_app_environment" {
  name                = "my-cae"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitor_rg.name

  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  infrastructure_subnet_id       = module.synthetic_monitoring_subnet[0].id
  internal_load_balancer_enabled = true

  tags = var.tags
}

# basic
module "monitoring_function" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//monitoring_function?ref=5cdc24a"

  location = "northeurope"
  prefix = "dvopla-d"
  resource_group_name = azurerm_resource_group.monitor_rg.name

  application_insight_name = azurerm_application_insights.application_insights.name
  application_insight_rg_name = azurerm_application_insights.application_insights.resource_group_name
  application_insights_action_group_ids = [azurerm_monitor_action_group.slack.id]

  docker_settings = {
    image_tag    = "beta-poc"
  }

  job_settings = {
    cron_scheduling              = "* * * 8 *"
    container_app_environment_id = azurerm_container_app_environment.monitoring_container_app_environment.id
  }

  storage_account_settings = {
    private_endpoint_enabled = false
    private_dns_zone_id      = null
  }

  monitoring_configuration_encoded = jsonencode( [{
        "apiName" : "aks_ingress",
        "appName": "microservice",
        "url": "https://dev01.blueprint.internal.devopslab.pagopa.it/blueprint/v5-java-helm-complete-test/",
        "type": "private",
        "checkCertificate": true,
        "method": "GET",
        "expectedCodes": ["200-299", "303"],
        "tags": {
            "description": "AKS ingress tested from internal network"
        },
        "durationLimit": 1000
    }] )

  tags = var.tags
}

# with private endpoint and custom alert configuration
module "monitoring_function" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//monitoring_function?ref=5cdc24a"

  location = "northeurope"
  prefix = "dvopla-d"
  resource_group_name = azurerm_resource_group.monitor_rg.name

  application_insight_name = azurerm_application_insights.application_insights.name
  application_insight_rg_name = azurerm_application_insights.application_insights.resource_group_name
  application_insights_action_group_ids = [azurerm_monitor_action_group.slack.id]

  docker_settings = {
    image_tag    = "beta-poc"
  }

  job_settings = {
    cron_scheduling              = "* * * 8 *"
    container_app_environment_id = azurerm_container_app_environment.monitoring_container_app_environment.id
  }

  storage_account_settings = {
    private_endpoint_enabled = true
    private_dns_zone_id      = azurerm_private_dns_zone.storage_account_table.id
  }
  
  private_endpoint_subnet_id = module.private_endpoints_snet.id
  
  monitoring_configuration_encoded = jsonencode( [{
        "apiName" : "aks_ingress",
        "appName": "microservice",
        "url": "https://dev01.blueprint.internal.devopslab.pagopa.it/blueprint/v5-java-helm-complete-test/",
        "type": "private",
        "checkCertificate": true,
        "method": "GET",
        "expectedCodes": ["200-299", "303"],
        "tags": {
            "description": "AKS ingress tested from internal network"
        },
        "durationLimit": 1000,
        # partial override of alert configuration
        "alertConfiguration": {
          "enabled" : false,
          "severity": 0
        }
    }] )
  
    # disables the alert on the availability metric monitoring this job itself
    self_alert_configuration = {
      enabled = false
    }

  tags = var.tags
}
```


<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | <= 1.11.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.85.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_synthetic_monitoring_storage_account"></a> [synthetic\_monitoring\_storage\_account](#module\_synthetic\_monitoring\_storage\_account) | git::https://github.com/pagopa/terraform-azurerm-v3.git//storage_account | v7.39.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.monitoring_app_job](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_monitor_metric_alert.alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.self_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_private_endpoint.synthetic_monitoring_storage_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_storage_table.table_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |
| [azurerm_storage_table_entity.monitoring_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table_entity) | resource |
| [azurerm_application_insights.app_insight](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_resource_group.parent_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_insight_name"></a> [application\_insight\_name](#input\_application\_insight\_name) | (Required) name of the application insight instance where to publish metrics | `string` | n/a | yes |
| <a name="input_application_insight_rg_name"></a> [application\_insight\_rg\_name](#input\_application\_insight\_rg\_name) | (Required) name of the application insight instance resource group where to publish metrics | `string` | n/a | yes |
| <a name="input_application_insights_action_group_ids"></a> [application\_insights\_action\_group\_ids](#input\_application\_insights\_action\_group\_ids) | (Required) Application insights action group ids | `list(string)` | n/a | yes |
| <a name="input_docker_settings"></a> [docker\_settings](#input\_docker\_settings) | n/a | <pre>object({<br>    registry_url = optional(string, "ghcr.io")                           #(Optional) Docker container registry url where to find the monitoring image<br>    image_tag    = string                                                #(Optional) Docker image tag<br>    image_name   = optional(string, "pagopa/azure-synthetic-monitoring") #(Optional) Docker image name<br>  })</pre> | <pre>{<br>  "image_name": "pagopa/azure-synthetic-monitoring",<br>  "image_tag": "1.0.0",<br>  "registry_url": "ghcr.io"<br>}</pre> | no |
| <a name="input_job_settings"></a> [job\_settings](#input\_job\_settings) | n/a | <pre>object({<br>    execution_timeout_seconds    = optional(number, 300)         #(Optional) Job execution timeout, in seconds<br>    cron_scheduling              = optional(string, "* * * * *") #(Optional) Cron expression defining the execution scheduling of the monitoring function<br>    cpu_requirement              = optional(number, 0.25)        #(Optional) Decimal; cpu requirement<br>    memory_requirement           = optional(string, "0.5Gi")     #(Optional) Memory requirement<br>    http_client_timeout          = optional(number, 30000)       #(Optional) Default http client timeout, in milliseconds<br>    default_duration_limit       = optional(number, 10000)       #(Optional) Duration limit applied if none is given in the monitoring configuration. in milliseconds<br>    availability_prefix          = optional(string, "synthetic") #(Optional) Prefix used for prefixing availability test names<br>    container_app_environment_id = string                        #(Required) If defined, the id of the container app environment tu be used to run the monitoring job. If provided, skips the creation of a dedicated subnet<br>    cert_validity_range_days     = optional(number, 7)           #(Optional) Number of days before the expiration date of a certificate over which the check is considered success<br>  })</pre> | <pre>{<br>  "availability_prefix": "synthetic",<br>  "cert_validity_range_days": 7,<br>  "container_app_environment_id": null,<br>  "cpu_requirement": 0.25,<br>  "cron_scheduling": "* * * * *",<br>  "default_duration_limit": 10000,<br>  "execution_timeout_seconds": 300,<br>  "http_client_timeout": 30000,<br>  "memory_requirement": "0.5Gi"<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Resource location | `string` | n/a | yes |
| <a name="input_monitoring_configuration_encoded"></a> [monitoring\_configuration\_encoded](#input\_monitoring\_configuration\_encoded) | (Required) monitoring configuration provided in JSON string format (use jsonencode) | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix used in the Velero dedicated resource names | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | (Optional) Subnet id where to create the private endpoint for backups storage account | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Name of the resource group in which the function and its related components are created | `string` | n/a | yes |
| <a name="input_self_alert_configuration"></a> [self\_alert\_configuration](#input\_self\_alert\_configuration) | Configuration for the alert on the job itself | <pre>object({<br>    enabled     = optional(bool, true)         # "(Optional) if true, enables the alert on the self monitoring availability metric"<br>    frequency   = optional(string, "PT1M")     # (Optional) The evaluation frequency of this Metric Alert, represented in ISO 8601 duration format. Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    severity    = optional(number, 0)          # (Optional) The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4<br>    threshold   = optional(number, 100)        # (Optional) The criteria threshold value that activates the alert<br>    operator    = optional(string, "LessThan") # (Optional) The criteria operator. Possible values are Equals, GreaterThan, GreaterThanOrEqual, LessThan and LessThanOrEqual<br>    aggregation = optional(string, "Average")  # (Required) The statistic that runs over the metric values. Possible values are Average, Count, Minimum, Maximum and Total.<br>  })</pre> | <pre>{<br>  "aggregation": "Average",<br>  "enabled": true,<br>  "frequency": "PT1M",<br>  "operator": "LessThan",<br>  "severity": 0,<br>  "threshold": 100<br>}</pre> | no |
| <a name="input_storage_account_settings"></a> [storage\_account\_settings](#input\_storage\_account\_settings) | n/a | <pre>object({<br>    tier                      = optional(string, "Standard")  #(Optional) Tier used for the backup storage account<br>    replication_type          = optional(string, "ZRS")       #(Optional) Replication type used for the backup storage account<br>    kind                      = optional(string, "StorageV2") #(Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2<br>    backup_retention_days     = optional(number, 0)           #(Optional) number of days for which the storage account is available for point in time recovery<br>    backup_enabled            = optional(bool, false)         # (Optional) enables storage account point in time recovery<br>    private_endpoint_enabled  = optional(bool, false)         #(Optional) enables the creation and usage of private endpoint<br>    table_private_dns_zone_id = string                        # (Optional) table storage private dns zone id<br>  })</pre> | <pre>{<br>  "backup_enabled": false,<br>  "backup_retention_days": 0,<br>  "kind": "StorageV2",<br>  "private_endpoint_enabled": false,<br>  "replication_type": "ZRS",<br>  "table_private_dns_zone_id": null,<br>  "tier": "Standard"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

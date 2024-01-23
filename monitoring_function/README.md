# Monitoring Function

This module creates the required resources used by a container app job which, based on a scheduling defined by a cron expression, monitors the configured apis and certificates, exporting the metrics to application insight

details on the function can be found [here](https://github.com/pagopa/azure-synthetic-monitoring)

## How to use it


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

module "monitoring_function" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//monitoring_function?ref=61dbf3f"

  location = "northeurope"
  prefix = "dvopla-d"

  resource_group_name = azurerm_resource_group.monitor_rg.name

  use_storage_private_endpoint = false

  monitoring_image_tag = "<tag>"
  container_app_environment_id = azurerm_container_app_environment.monitoring_container_app_environment.id
  app_insight_connection_string = azurerm_application_insights.application_insights.connection_string

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
| [azurerm_private_endpoint.synthetic_monitoring_storage_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.parent_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_insight_connection_string"></a> [app\_insight\_connection\_string](#input\_app\_insight\_connection\_string) | (Required) App insight connection string where metrics will be published | `string` | n/a | yes |
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | (Optional) If defined, the id of the container app environment tu be used to run the monitoring job. If provided, skips the creation of a dedicated subnet | `string` | `null` | no |
| <a name="input_cpu_requirement"></a> [cpu\_requirement](#input\_cpu\_requirement) | (Optional) Decimal; cpu requirement | `number` | `0.25` | no |
| <a name="input_cron_scheduling"></a> [cron\_scheduling](#input\_cron\_scheduling) | (Optional) Cron expression defining the execution scheduling of the monitoring function | `string` | `"* * * * *"` | no |
| <a name="input_enable_sa_backup"></a> [enable\_sa\_backup](#input\_enable\_sa\_backup) | (Optional) enables storage account point in time recovery | `bool` | `false` | no |
| <a name="input_execution_timeout_seconds"></a> [execution\_timeout\_seconds](#input\_execution\_timeout\_seconds) | (Optional) Job execution timeout, in seconds | `number` | `300` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Resource location | `string` | n/a | yes |
| <a name="input_memory_requirement"></a> [memory\_requirement](#input\_memory\_requirement) | (Optional) Memory requirement | `string` | `"0.5Gi"` | no |
| <a name="input_monitoring_image_name"></a> [monitoring\_image\_name](#input\_monitoring\_image\_name) | (Optional) Docker image name | `string` | `"pagopa/azure-synthetic-monitoring"` | no |
| <a name="input_monitoring_image_tag"></a> [monitoring\_image\_tag](#input\_monitoring\_image\_tag) | (Optional) Docker image tag | `string` | `"1.0.0"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix used in the Velero dedicated resource names | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | (Optional) Subnet id where to create the private endpoint for backups storage account | `string` | `null` | no |
| <a name="input_registry_url"></a> [registry\_url](#input\_registry\_url) | (Optional) Docker container registry url where to find the monitoring image | `string` | `"ghcr.io"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Name of the resource group in which the function and its related components are created | `string` | n/a | yes |
| <a name="input_sa_backup_retention_days"></a> [sa\_backup\_retention\_days](#input\_sa\_backup\_retention\_days) | (Optional) number of days for which the storage account is available for point in time recovery | `number` | `0` | no |
| <a name="input_storage_account_kind"></a> [storage\_account\_kind](#input\_storage\_account\_kind) | (Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2 | `string` | `"StorageV2"` | no |
| <a name="input_storage_account_private_dns_zone_id"></a> [storage\_account\_private\_dns\_zone\_id](#input\_storage\_account\_private\_dns\_zone\_id) | (Optional) Storage account private dns zone id, used in the private endpoint creation | `string` | `null` | no |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | (Optional) Replication type used for the backup storage account | `string` | `"ZRS"` | no |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | (Optional) Tier used for the backup storage account | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_use_storage_private_endpoint"></a> [use\_storage\_private\_endpoint](#input\_use\_storage\_private\_endpoint) | (Optional) Whether to make the storage account private and use a private endpoint to connect | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

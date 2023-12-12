# Postgres Flexible Server Replica

Module that allows the creation of a postgres flexible replica

## Production Ready

> See how to use in production: <https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/484474896/Postgres+Flexible>



## Connection to DB

* if **pgbounce** is enabled: the port is 6432, otherwise: 5432

## Limits and constraints

* **HA** and **pg bouncer** is not avaible for `B series` machines


## Metrics

By default the module has his own metrics (replica lag in bytes and in seconds), but if you want to add your own metrics you can use the parameters `main_server_additional_alerts` and `replica_server_metric_alerts` with this example structure:
They will be added to the already provided metrics
```ts
variable "main_server_additional_alerts" {
  description = <<EOD
  Map of name = criteria objects
  EOD

  type = map(object({
    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
    aggregation = string
    # "Insights.Container/pods" "Insights.Container/nodes"
    metric_namespace = string
    metric_name      = string
    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
    operator  = string
    threshold = number
    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H
    frequency = string
    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.
    window_size = string
    # severity: The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 3. Lower is worst
    severity = number
  }))

  default = {
    cpu_percent = {
      frequency        = "PT1M"
      window_size      = "PT5M"
      metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
      aggregation      = "Average"
      metric_name      = "cpu_percent"
      operator         = "GreaterThan"
      threshold        = 80
      severity = 2
    }
  }
}
```

## How to use it

```hcl
  data "azurerm_virtual_network" "vnet_replica" {
    name                = local.vnet_replica_name
    resource_group_name = local.vnet_resource_group_name
  }

  # Postgres Flexible Server subnet
  module "postgres_flexible_snet_replica" {
    count = var.geo_replica_enabled ? 1 : 0
    source                                        = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v6.2.1"
    name                                          = "${local.project_replica}-pgres-flexible-snet"
    address_prefixes                              = var.geo_replica_cidr_subnet_postgresql
    resource_group_name                           = data.azurerm_resource_group.rg_vnet.name
    virtual_network_name                          = data.azurerm_virtual_network.vnet_replica.name
    service_endpoints                             = ["Microsoft.Storage"]
    private_link_service_network_policies_enabled = true
  
    delegation = {
      name = "delegation"
      service_delegation = {
        name = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
        ]
      }
    }
  }

  # DNS private single server
  resource "azurerm_private_dns_zone" "privatelink_postgres_database_azure_com" {

    name                = "privatelink.postgres.database.azure.com"
    resource_group_name = data.azurerm_resource_group.rg_vnet.name

    tags = var.tags
  }

  resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_postgres_database_azure_com_vnet" {

    name                  = "${local.program}-pg-flex-link"
    private_dns_zone_name = azurerm_private_dns_zone.privatelink_postgres_database_azure_com.name

    resource_group_name = data.azurerm_resource_group.rg_vnet.name
    virtual_network_id  = data.azurerm_virtual_network.vnet.id

    registration_enabled = false

    tags = var.tags
  }

  module "postgresql_fdr_replica_db" {
    source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//postgres_flexible_server_replica?ref=<version>"
    count = var.geo_replica_enabled ? 1 : 0
  
    name = "${local.project_replica}-flexible-postgresql"
    resource_group_name = azurerm_resource_group.db_rg.name
    location = var.location_replica
  
    private_dns_zone_id = var.env_short != "d" ? data.azurerm_private_dns_zone.postgres[0].id : null
    delegated_subnet_id = module.postgres_flexible_snet_replica[0].id
    private_endpoint_enabled = var.pgres_flex_params.pgres_flex_private_endpoint_enabled
  
    sku_name = var.pgres_flex_params.sku_name
  
    high_availability_enabled = false
    pgbouncer_enabled = var.pgres_flex_params.pgres_flex_pgbouncer_enabled
  
    source_server_id = module.postgres_flexible_server_fdr.id # the original server id to which we want to add a replica
  
    diagnostic_settings_enabled = false
  
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id
    zone = 2
    tags = var.tags
  }
```


See [Generic resorce migration](../docs/MIGRATION_GUIDE_GENERIC_RESOURCES.md)

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.71.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.main_server_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.replica_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.pgbouncer_enabled](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [null_resource.ha_sku_check](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.pgbouncer_check](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_action"></a> [alert\_action](#input\_alert\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br>    {<br>      action_group_id    = string<br>      webhook_properties = map(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_alerts_enabled"></a> [alerts\_enabled](#input\_alerts\_enabled) | Should Metrics Alert be enabled? | `bool` | `true` | no |
| <a name="input_delegated_subnet_id"></a> [delegated\_subnet\_id](#input\_delegated\_subnet\_id) | (Optional) The ID of the virtual network subnet to create the PostgreSQL Flexible Server. The provided subnet should not have any other resource deployed in it and this subnet will be delegated to the PostgreSQL Flexible Server, if not already delegated. | `string` | `null` | no |
| <a name="input_diagnostic_setting_destination_storage_id"></a> [diagnostic\_setting\_destination\_storage\_id](#input\_diagnostic\_setting\_destination\_storage\_id) | (Optional) The ID of the Storage Account where logs should be sent. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_diagnostic_settings_enabled"></a> [diagnostic\_settings\_enabled](#input\_diagnostic\_settings\_enabled) | Is diagnostic settings enabled? | `bool` | `true` | no |
| <a name="input_high_availability_enabled"></a> [high\_availability\_enabled](#input\_high\_availability\_enabled) | (Required) Is the High Availability Enabled | `bool` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure Region where the PostgreSQL Flexible Server should exist. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent. | `string` | `null` | no |
| <a name="input_main_server_additional_alerts"></a> [main\_server\_additional\_alerts](#input\_main\_server\_additional\_alerts) | Map of name = criteria objects | <pre>map(object({<br>    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>    aggregation = string<br>    metric_name = string<br>    # "Insights.Container/pods" "Insights.Container/nodes"<br>    metric_namespace = string<br>    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>    operator  = string<br>    threshold = number<br>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    frequency = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br>    window_size = string<br>    # severity: The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 3.<br>    severity = number<br>  }))</pre> | `{}` | no |
| <a name="input_maintenance_window_config"></a> [maintenance\_window\_config](#input\_maintenance\_window\_config) | (Optional) Allows the configuration of the maintenance window, if not configured default is Wednesday@2.00am | <pre>object({<br>    day_of_week  = number<br>    start_hour   = number<br>    start_minute = number<br>  })</pre> | <pre>{<br>  "day_of_week": 3,<br>  "start_hour": 2,<br>  "start_minute": 0<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name which should be used for this PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created. | `string` | n/a | yes |
| <a name="input_pgbouncer_enabled"></a> [pgbouncer\_enabled](#input\_pgbouncer\_enabled) | Is PgBouncer enabled into configurations? | `bool` | `true` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | (Optional) The ID of the private dns zone to create the PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created. | `string` | `null` | no |
| <a name="input_private_endpoint_enabled"></a> [private\_endpoint\_enabled](#input\_private\_endpoint\_enabled) | Is this instance private only? | `bool` | n/a | yes |
| <a name="input_replica_server_metric_alerts"></a> [replica\_server\_metric\_alerts](#input\_replica\_server\_metric\_alerts) | Map of name = criteria objects | <pre>map(object({<br>    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>    aggregation = string<br>    metric_name = string<br>    # "Insights.Container/pods" "Insights.Container/nodes"<br>    metric_namespace = string<br>    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>    operator  = string<br>    threshold = number<br>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    frequency = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br>    window_size = string<br>    # severity: The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 3.<br>    severity = number<br>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group where the PostgreSQL Flexible Server should exist. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern (e.g. B\_Standard\_B1ms, GP\_Standard\_D2s\_v3, MO\_Standard\_E4s\_v3). | `string` | n/a | yes |
| <a name="input_source_server_id"></a> [source\_server\_id](#input\_source\_server\_id) | (Required) Id of the source server to be replicated | `string` | n/a | yes |
| <a name="input_standby_availability_zone"></a> [standby\_availability\_zone](#input\_standby\_availability\_zone) | (Optional) Specifies the Availability Zone in which the standby Flexible Server should be located. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | (Optional) Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_port"></a> [connection\_port](#output\_connection\_port) | n/a |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_public_access_enabled"></a> [public\_access\_enabled](#output\_public\_access\_enabled) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

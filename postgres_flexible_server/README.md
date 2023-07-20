# Postgres Flexible Server

Module that allows the creation of a postgres flexible.

## Production Ready

> See how to use in production: <https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/484474896/Postgres+Flexible>

## Architecture

![architecture](./docs/module-arch.drawio.png)

## Connection to DB

* if **pgbounce** is enabled: the port is 6432, otherwise: 5432

## Limits and constraints

* **HA** and **pg bouncer** is not avaible for `B series` machines

## Customer managed key

It's now possible to use a `Customer managed key`. To achieve this result you need to set:
```
customer_managed_key_enabled      = true (default = false)
```
Please have a look at the example in the `tests` folder to understand how to proceed and see a working example.

## Metrics

By default the module has his own metrics, but if you want to override it you can use the parameter `custom_metric_alerts` with this example structure:

```ts
variable "pgflex_public_metric_alerts" {
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

## How to use it (Public mode & Private mode)

```ts
  # KV secrets flex server
  data "azurerm_key_vault_secret" "pgres_flex_admin_login" {
    name         = "pgres-flex-admin-login"
    key_vault_id = data.azurerm_key_vault.kv.id
  }

  data "azurerm_key_vault_secret" "pgres_flex_admin_pwd" {
    name         = "pgres-flex-admin-pwd"
    key_vault_id = data.azurerm_key_vault.kv.id
  }

  #------------------------------------------------
  resource "azurerm_resource_group" "postgres_dbs" {
    name     = "${local.program}-postgres-dbs-rg"
    location = var.location

    tags = var.tags
  }

  # Postgres Flexible Server subnet
  module "postgres_flexible_snet" {
    source                                    = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v3.15.0"
    name                                      = "${local.program}-pgres-flexible-snet"
    address_prefixes                          = var.cidr_subnet_flex_dbms
    resource_group_name                       = data.azurerm_resource_group.rg_vnet.name
    virtual_network_name                      = data.azurerm_virtual_network.vnet.name
    service_endpoints                         = ["Microsoft.Storage"]
    private_endpoint_network_policies_enabled = true

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

  # https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compare-single-server-flexible-server
  module "postgres_flexible_server_private" {

    count = var.pgflex_private_config.enabled ? 1 : 0

    source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//postgres_flexible_server?ref=v3.15.0"

    name                = "${local.program}-private-pgflex"
    location            = azurerm_resource_group.postgres_dbs.location
    resource_group_name = azurerm_resource_group.postgres_dbs.name

    ### Network
    private_endpoint_enabled = false
    private_dns_zone_id      = azurerm_private_dns_zone.privatelink_postgres_database_azure_com.id
    delegated_subnet_id      = module.postgres_flexible_snet.id

    ### Admin
    administrator_login    = data.azurerm_key_vault_secret.pgres_flex_admin_login.value
    administrator_password = data.azurerm_key_vault_secret.pgres_flex_admin_pwd.value

    sku_name   = "B_Standard_B1ms"
    db_version = "13"
    # Possible values are 32768, 65536, 131072, 262144, 524288, 1048576,
    # 2097152, 4194304, 8388608, 16777216, and 33554432.
    storage_mb = 32768

    ### zones & HA
    zone                      = 1
    high_availability_enabled = false
    standby_availability_zone = 3

    maintenance_window_config = {
      day_of_week  = 0
      start_hour   = 2
      start_minute = 0
    }

    ### backup
    backup_retention_days        = 7
    geo_redundant_backup_enabled = false

    pgbouncer_enabled = false

    tags = var.tags

    custom_metric_alerts = var.pgflex_public_metric_alerts
    alerts_enabled       = true

    diagnostic_settings_enabled               = true
    log_analytics_workspace_id                = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
    diagnostic_setting_destination_storage_id = data.azurerm_storage_account.security_monitoring_storage.id

    depends_on = [azurerm_private_dns_zone_virtual_network_link.privatelink_postgres_database_azure_com_vnet]

  }

  #
  # Public Flexible
  #

  # https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compare-single-server-flexible-server
  module "postgres_flexible_server_public" {

    count = var.pgflex_public_config.enabled ? 1 : 0

    source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//postgres_flexible_server?ref=v3.15.0"

    name                = "${local.program}-public-pgflex"
    location            = azurerm_resource_group.postgres_dbs.location
    resource_group_name = azurerm_resource_group.postgres_dbs.name

    administrator_login    = data.azurerm_key_vault_secret.pgres_flex_admin_login.value
    administrator_password = data.azurerm_key_vault_secret.pgres_flex_admin_pwd.value

    sku_name   = "B_Standard_B1ms"
    db_version = "13"
    # Possible values are 32768, 65536, 131072, 262144, 524288, 1048576,
    # 2097152, 4194304, 8388608, 16777216, and 33554432.
    storage_mb                   = 32768
    zone                         = 1
    backup_retention_days        = 7
    geo_redundant_backup_enabled = false

    high_availability_enabled = false
    private_endpoint_enabled  = false
    pgbouncer_enabled         = false

    tags = var.tags

    custom_metric_alerts = var.pgflex_public_metric_alerts
    alerts_enabled       = true

    diagnostic_settings_enabled               = true
    log_analytics_workspace_id                = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
    diagnostic_setting_destination_storage_id = data.azurerm_storage_account.security_monitoring_storage.id

  }
```

## Migration from v2

### 🔥 re-import the resource azurerm_monitor_diagnostic_setting

Is possible that you need to re-import this resource

```ts
module.postgres_flexible_server_public[0].azurerm_monitor_diagnostic_setting.this[0]
```

See [Generic resorce migration](../docs/MIGRATION_GUIDE_GENERIC_RESOURCES.md)

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.64.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.64.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.pgbouncer_enabled](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [null_resource.ha_sku_check](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.pgbouncer_check](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | Flexible PostgreSql server administrator\_login | `string` | n/a | yes |
| <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password) | Flexible PostgreSql server administrator\_password | `string` | n/a | yes |
| <a name="input_alert_action"></a> [alert\_action](#input\_alert\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br>    {<br>      action_group_id    = string<br>      webhook_properties = map(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_alerts_enabled"></a> [alerts\_enabled](#input\_alerts\_enabled) | Should Metrics Alert be enabled? | `bool` | `true` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | (Optional) The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days. | `number` | `7` | no |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | (Optional) The creation mode. Can be used to restore or replicate existing servers. Possible values are Default, Replica, GeoRestore, and PointInTimeRestore | `string` | `"Default"` | no |
| <a name="input_custom_metric_alerts"></a> [custom\_metric\_alerts](#input\_custom\_metric\_alerts) | Map of name = criteria objects | <pre>map(object({<br>    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>    aggregation = string<br>    metric_name = string<br>    # "Insights.Container/pods" "Insights.Container/nodes"<br>    metric_namespace = string<br>    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>    operator  = string<br>    threshold = number<br>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    frequency = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br>    window_size = string<br>    # severity: The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 3.<br>    severity = number<br>  }))</pre> | `null` | no |
| <a name="input_customer_managed_key_enabled"></a> [customer\_managed\_key\_enabled](#input\_customer\_managed\_key\_enabled) | enable customer\_managed\_key | `bool` | `"false"` | no |
| <a name="input_customer_managed_key_kv_key_id"></a> [customer\_managed\_key\_kv\_key\_id](#input\_customer\_managed\_key\_kv\_key\_id) | The ID of the Key Vault Key | `string` | `null` | no |
| <a name="input_db_version"></a> [db\_version](#input\_db\_version) | (Required) The version of PostgreSQL Flexible Server to use. Possible values are 11,12 and 13. Required when create\_mode is Default | `number` | n/a | yes |
| <a name="input_default_metric_alerts"></a> [default\_metric\_alerts](#input\_default\_metric\_alerts) | Map of name = criteria objects | <pre>map(object({<br>    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>    aggregation = string<br>    metric_name = string<br>    # "Insights.Container/pods" "Insights.Container/nodes"<br>    metric_namespace = string<br>    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>    operator  = string<br>    threshold = number<br>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    frequency = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br>    window_size = string<br>    # severity: The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 3.<br>    severity = number<br>  }))</pre> | <pre>{<br>  "active_connections": {<br>    "aggregation": "Average",<br>    "frequency": "PT5M",<br>    "metric_name": "active_connections",<br>    "metric_namespace": "Microsoft.DBforPostgreSQL/flexibleServers",<br>    "operator": "GreaterThan",<br>    "severity": 2,<br>    "threshold": 80,<br>    "window_size": "PT30M"<br>  },<br>  "connections_failed": {<br>    "aggregation": "Total",<br>    "frequency": "PT5M",<br>    "metric_name": "connections_failed",<br>    "metric_namespace": "Microsoft.DBforPostgreSQL/flexibleServers",<br>    "operator": "GreaterThan",<br>    "severity": 2,<br>    "threshold": 80,<br>    "window_size": "PT30M"<br>  },<br>  "cpu_percent": {<br>    "aggregation": "Average",<br>    "frequency": "PT5M",<br>    "metric_name": "cpu_percent",<br>    "metric_namespace": "Microsoft.DBforPostgreSQL/flexibleServers",<br>    "operator": "GreaterThan",<br>    "severity": 2,<br>    "threshold": 80,<br>    "window_size": "PT30M"<br>  },<br>  "memory_percent": {<br>    "aggregation": "Average",<br>    "frequency": "PT5M",<br>    "metric_name": "memory_percent",<br>    "metric_namespace": "Microsoft.DBforPostgreSQL/flexibleServers",<br>    "operator": "GreaterThan",<br>    "severity": 2,<br>    "threshold": 80,<br>    "window_size": "PT30M"<br>  },<br>  "storage_percent": {<br>    "aggregation": "Average",<br>    "frequency": "PT5M",<br>    "metric_name": "storage_percent",<br>    "metric_namespace": "Microsoft.DBforPostgreSQL/flexibleServers",<br>    "operator": "GreaterThan",<br>    "severity": 2,<br>    "threshold": 80,<br>    "window_size": "PT30M"<br>  }<br>}</pre> | no |
| <a name="input_delegated_subnet_id"></a> [delegated\_subnet\_id](#input\_delegated\_subnet\_id) | (Optional) The ID of the virtual network subnet to create the PostgreSQL Flexible Server. The provided subnet should not have any other resource deployed in it and this subnet will be delegated to the PostgreSQL Flexible Server, if not already delegated. | `string` | `null` | no |
| <a name="input_diagnostic_setting_destination_storage_id"></a> [diagnostic\_setting\_destination\_storage\_id](#input\_diagnostic\_setting\_destination\_storage\_id) | (Optional) The ID of the Storage Account where logs should be sent. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_diagnostic_settings_enabled"></a> [diagnostic\_settings\_enabled](#input\_diagnostic\_settings\_enabled) | Is diagnostic settings enabled? | `bool` | `true` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | (Optional) Is Geo-Redundant backup enabled on the PostgreSQL Flexible Server. Defaults to false | `bool` | `false` | no |
| <a name="input_high_availability_enabled"></a> [high\_availability\_enabled](#input\_high\_availability\_enabled) | (Required) Is the High Availability Enabled | `bool` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure Region where the PostgreSQL Flexible Server should exist. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent. | `string` | `null` | no |
| <a name="input_maintenance_window_config"></a> [maintenance\_window\_config](#input\_maintenance\_window\_config) | (Optional) Allows the configuration of the maintenance window, if not configured default is Wednesday@2.00am | <pre>object({<br>    day_of_week  = number<br>    start_hour   = number<br>    start_minute = number<br>  })</pre> | <pre>{<br>  "day_of_week": 3,<br>  "start_hour": 2,<br>  "start_minute": 0<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name which should be used for this PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created. | `string` | n/a | yes |
| <a name="input_pgbouncer_enabled"></a> [pgbouncer\_enabled](#input\_pgbouncer\_enabled) | Is PgBouncer enabled into configurations? | `bool` | `true` | no |
| <a name="input_primary_user_assigned_identity_id"></a> [primary\_user\_assigned\_identity\_id](#input\_primary\_user\_assigned\_identity\_id) | Manages a User Assigned Identity | `string` | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | (Optional) The ID of the private dns zone to create the PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created. | `string` | `null` | no |
| <a name="input_private_endpoint_enabled"></a> [private\_endpoint\_enabled](#input\_private\_endpoint\_enabled) | Is this instance private only? | `bool` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group where the PostgreSQL Flexible Server should exist. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern (e.g. B\_Standard\_B1ms, GP\_Standard\_D2s\_v3, MO\_Standard\_E4s\_v3). | `string` | n/a | yes |
| <a name="input_standby_availability_zone"></a> [standby\_availability\_zone](#input\_standby\_availability\_zone) | (Optional) Specifies the Availability Zone in which the standby Flexible Server should be located. | `number` | `null` | no |
| <a name="input_storage_mb"></a> [storage\_mb](#input\_storage\_mb) | The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, and 33554432. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | (Optional) Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_administrator_login"></a> [administrator\_login](#output\_administrator\_login) | n/a |
| <a name="output_administrator_password"></a> [administrator\_password](#output\_administrator\_password) | n/a |
| <a name="output_connection_port"></a> [connection\_port](#output\_connection\_port) | n/a |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_public_access_enabled"></a> [public\_access\_enabled](#output\_public\_access\_enabled) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

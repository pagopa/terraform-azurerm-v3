# Postgresql_server

Module that allow the creation of a postgres sql server (no flexible!)

## How to use it

```ts
locals {
  postgres = {
    metric_alerts = {
      cpu = {
        aggregation = "Average"
        metric_name = "cpu_percent"
        operator    = "GreaterThan"
        threshold   = 70
        frequency   = "PT1M"
        window_size = "PT5M"
        dimension   = []
      }
      memory = {
        aggregation = "Average"
        metric_name = "memory_percent"
        operator    = "GreaterThan"
        threshold   = 75
        frequency   = "PT1M"
        window_size = "PT5M"
        dimension   = []
      }
      io = {
        aggregation = "Average"
        metric_name = "io_consumption_percent"
        operator    = "GreaterThan"
        threshold   = 55
        frequency   = "PT1M"
        window_size = "PT5M"
        dimension   = []
      }
      # https://docs.microsoft.com/it-it/azure/postgresql/concepts-limits
      # GP_Gen5_2 -| 145 / 100 * 80 = 116
      # GP_Gen5_32 -| 1495 / 100 * 80 = 1196
      max_active_connections = {
        aggregation = "Average"
        metric_name = "active_connections"
        operator    = "GreaterThan"
        threshold   = 1196
        frequency   = "PT5M"
        window_size = "PT5M"
        dimension   = []
      }
      min_active_connections = {
        aggregation = "Average"
        metric_name = "active_connections"
        operator    = "LessThanOrEqual"
        threshold   = 0
        frequency   = "PT5M"
        window_size = "PT15M"
        dimension   = []
      }
      failed_connections = {
        aggregation = "Total"
        metric_name = "connections_failed"
        operator    = "GreaterThan"
        threshold   = 10
        frequency   = "PT5M"
        window_size = "PT15M"
        dimension   = []
      }
      replica_lag = {
        aggregation = "Average"
        metric_name = "pg_replica_log_delay_in_seconds"
        operator    = "GreaterThan"
        threshold   = 60
        frequency   = "PT1M"
        window_size = "PT5M"
        dimension   = []
      }
    }
  }
}

data "azurerm_key_vault_secret" "postgres_administrator_login" {
  name         = "postgres-administrator-login"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "postgres_administrator_login_password" {
  name         = "postgres-administrator-login-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}

#--------------------------------------------------------------------------------------------------

resource "azurerm_resource_group" "data_rg" {
  name     = "${local.project}-data-rg"
  location = var.location

  tags = var.tags
}

## Database subnet
module "postgres_snet" {
  source                                    = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=8.5.0"
  name                                      = "${local.project}-postgres-snet"
  address_prefixes                          = var.cidr_subnet_postgres
  resource_group_name                       = azurerm_resource_group.rg_vnet.name
  virtual_network_name                      = module.vnet.name
  service_endpoints                         = ["Microsoft.Sql"]
  private_endpoint_network_policies_enabled = true
}

module "postgres" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//postgresql_server?ref=8.5.0"

  name                = "${local.project}-postgres"
  location            = azurerm_resource_group.data_rg.location
  resource_group_name = azurerm_resource_group.data_rg.name

  administrator_login          = data.azurerm_key_vault_secret.postgres_administrator_login.value
  administrator_login_password = data.azurerm_key_vault_secret.postgres_administrator_login_password.value
  sku_name                     = "B_Gen5_1"
  db_version                   = 11
  geo_redundant_backup_enabled = false

  public_network_access_enabled = var.env_short == "p" ? false : var.postgres_public_network_access_enabled
  network_rules                 = var.postgres_network_rules
  private_endpoint = {
    enabled              = false
    virtual_network_id   = azurerm_resource_group.rg_vnet.id
    subnet_id            = module.postgres_snet.id
    private_dns_zone_ids = []
  }

  alerts_enabled                = var.postgres_alerts_enabled
  monitor_metric_alert_criteria = local.postgres.metric_alerts
  action = [
    {
      action_group_id    = azurerm_monitor_action_group.email.id
      webhook_properties = null
    },
    {
      action_group_id    = azurerm_monitor_action_group.slack.id
      webhook_properties = null
    }
  ]

  lock_enable = var.lock_enable

  tags = var.tags
}
```

## Migration from v2

Caused by a drift into the upgrade is possible that you need to destroy the state and import the resources

```sh
terraform state rm module.postgres.azurerm_postgresql_server.this
```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.97.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.replica](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_metric_alert.replica](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_postgresql_configuration.replica](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_configuration) | resource |
| [azurerm_postgresql_configuration.replica_connection_throttling](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_configuration) | resource |
| [azurerm_postgresql_configuration.replica_log_checkpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_configuration) | resource |
| [azurerm_postgresql_configuration.replica_log_connections](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_configuration) | resource |
| [azurerm_postgresql_configuration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_configuration) | resource |
| [azurerm_postgresql_configuration.this_connection_throttling](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_configuration) | resource |
| [azurerm_postgresql_configuration.this_log_checkpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_configuration) | resource |
| [azurerm_postgresql_configuration.this_log_connections](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_configuration) | resource |
| [azurerm_postgresql_firewall_rule.azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_firewall_rule) | resource |
| [azurerm_postgresql_firewall_rule.azure_replica](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_firewall_rule) | resource |
| [azurerm_postgresql_firewall_rule.replica](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_firewall_rule) | resource |
| [azurerm_postgresql_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_firewall_rule) | resource |
| [azurerm_postgresql_server.replica](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server) | resource |
| [azurerm_postgresql_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server) | resource |
| [azurerm_postgresql_virtual_network_rule.replica](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_virtual_network_rule) | resource |
| [azurerm_postgresql_virtual_network_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_virtual_network_rule) | resource |
| [azurerm_private_endpoint.replica](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br>    {<br>      action_group_id    = string<br>      webhook_properties = map(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | The Administrator Login for the PostgreSQL Server. | `string` | n/a | yes |
| <a name="input_administrator_login_password"></a> [administrator\_login\_password](#input\_administrator\_login\_password) | The Password associated with the administrator\_login for the PostgreSQL Server. | `string` | n/a | yes |
| <a name="input_alerts_enabled"></a> [alerts\_enabled](#input\_alerts\_enabled) | Should Metric Alerts be enabled? | `bool` | `true` | no |
| <a name="input_allowed_subnets"></a> [allowed\_subnets](#input\_allowed\_subnets) | (Optional) Allowed subnets ids | `list(string)` | `[]` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Backup retention days for the server, supported values are between | `number` | `7` | no |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | Map with PostgreSQL configurations. | `map(string)` | `{}` | no |
| <a name="input_configuration_replica"></a> [configuration\_replica](#input\_configuration\_replica) | Map with PostgreSQL configurations. | `map(string)` | `{}` | no |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | The creation mode. Can be used to restore or replicate existing servers. Possible values are Default, Replica, GeoRestore, and PointInTimeRestore | `string` | `"Default"` | no |
| <a name="input_creation_source_server_id"></a> [creation\_source\_server\_id](#input\_creation\_source\_server\_id) | For creation modes other then default the source server ID to use. | `string` | `null` | no |
| <a name="input_db_version"></a> [db\_version](#input\_db\_version) | Specifies the version of PostgreSQL to use. | `number` | n/a | yes |
| <a name="input_enable_replica"></a> [enable\_replica](#input\_enable\_replica) | Create a replica server | `bool` | `false` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | Turn Geo-redundant server backups on/off. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_lock_enable"></a> [lock\_enable](#input\_lock\_enable) | Apply lock to block accedentaly deletions. | `bool` | `false` | no |
| <a name="input_monitor_metric_alert_criteria"></a> [monitor\_metric\_alert\_criteria](#input\_monitor\_metric\_alert\_criteria) | Map of name = criteria objects, see these docs for options<br>https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftdbforpostgresqlservers<br>https://docs.microsoft.com/en-us/azure/postgresql/concepts-limits#maximum-connections | <pre>map(object({<br>    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>    aggregation = string<br>    metric_name = string<br>    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>    operator  = string<br>    threshold = number<br>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    frequency = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br>    window_size = string<br><br>    dimension = list(object(<br>      {<br>        name     = string<br>        operator = string<br>        values   = list(string)<br>      }<br>    ))<br>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network rules restricting access to the postgresql server. | <pre>object({<br>    ip_rules                       = list(string)<br>    allow_access_to_azure_services = bool<br>  })</pre> | <pre>{<br>  "allow_access_to_azure_services": false,<br>  "ip_rules": []<br>}</pre> | no |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | (Required) Enable vnet private endpoint with required params | <pre>object({<br>    enabled              = bool<br>    virtual_network_id   = string<br>    subnet_id            = string<br>    private_dns_zone_ids = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether or not public network access is allowed for this server. | `bool` | `false` | no |
| <a name="input_replica_action"></a> [replica\_action](#input\_replica\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br>    {<br>      action_group_id    = string<br>      webhook_properties = map(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_replica_allowed_subnets"></a> [replica\_allowed\_subnets](#input\_replica\_allowed\_subnets) | (Optional) Allowed subnets ids | `list(string)` | `[]` | no |
| <a name="input_replica_monitor_metric_alert_criteria"></a> [replica\_monitor\_metric\_alert\_criteria](#input\_replica\_monitor\_metric\_alert\_criteria) | Map of name = criteria objects, see these docs for options<br>https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftdbforpostgresqlservers<br>https://docs.microsoft.com/en-us/azure/postgresql/concepts-limits#maximum-connections | <pre>map(object({<br>    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>    aggregation = string<br>    metric_name = string<br>    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>    operator  = string<br>    threshold = number<br>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    frequency = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br>    window_size = string<br><br>    dimension = list(object(<br>      {<br>        name     = string<br>        operator = string<br>        values   = list(string)<br>      }<br>    ))<br>  }))</pre> | `{}` | no |
| <a name="input_replica_network_rules"></a> [replica\_network\_rules](#input\_replica\_network\_rules) | Network rules restricting access to the replica postgresql server. | <pre>object({<br>    ip_rules                       = list(string)<br>    allow_access_to_azure_services = bool<br>  })</pre> | <pre>{<br>  "allow_access_to_azure_services": false,<br>  "ip_rules": []<br>}</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_restore_point_in_time"></a> [restore\_point\_in\_time](#input\_restore\_point\_in\_time) | When create\_mode is PointInTimeRestore the point in time to restore from creation\_source\_server\_id. | `string` | `null` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Specifies the SKU Name for this PostgreSQL Server. | `string` | n/a | yes |
| <a name="input_ssl_enforcement_enabled"></a> [ssl\_enforcement\_enabled](#input\_ssl\_enforcement\_enabled) | Specifies if SSL should be enforced on connections. | `bool` | `true` | no |
| <a name="input_ssl_minimal_tls_version_enforced"></a> [ssl\_minimal\_tls\_version\_enforced](#input\_ssl\_minimal\_tls\_version\_enforced) | The mimimun TLS version to support on the sever | `string` | `"TLS1_2"` | no |
| <a name="input_storage_mb"></a> [storage\_mb](#input\_storage\_mb) | Max storage allowed for a server. Possible values are between 5120 MB(5GB) and 1048576 MB(1TB) for the Basic SKU and between 5120 MB(5GB) and 16777216 MB(16TB) for General Purpose/Memory Optimized SKUs. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_administrator_login"></a> [administrator\_login](#output\_administrator\_login) | n/a |
| <a name="output_administrator_login_password"></a> [administrator\_login\_password](#output\_administrator\_login\_password) | n/a |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | n/a |
| <a name="output_replica_fqdn"></a> [replica\_fqdn](#output\_replica\_fqdn) | n/a |
| <a name="output_replica_name"></a> [replica\_name](#output\_replica\_name) | n/a |
| <a name="output_replica_principal_id"></a> [replica\_principal\_id](#output\_replica\_principal\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

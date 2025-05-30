# Cosmos DB account

This module allow the setup of a cosmos db account

## Architecture

![This is an image](./docs/module-arch.drawio.png)

## How to use

### CosmosDB Mongo version

```ts
module "cosmos_mongo" {
  source   = "git::https://github.com/pagopa/terraform-azurerm-v3.git//cosmosdb_account?ref=v8.8.0"
  name     = "${local.project}-cosmos-mongo"
  location = var.location
  domain   = var.domain

  resource_group_name  = azurerm_resource_group.cosmos_mongo_rg[0].name
  offer_type           = "Standard"
  kind                 = "MongoDB"
  capabilities         = ["EnableMongo"]
  mongo_server_version = "4.0"

  main_geo_location_zone_redundant = false

  enable_free_tier          = false
  enable_automatic_failover = true

  consistency_policy = {
    consistency_level       = "Strong"
    max_interval_in_seconds = null
    max_staleness_prefix    = null
  }

  main_geo_location_location = "northeurope"

  additional_geo_locations = [
    {
      location          = "westeurope"
      failover_priority = 1
      zone_redundant    = false
    }
  ]

  backup_continuous_enabled = true

  is_virtual_network_filter_enabled = true

  ip_range = ""

  allowed_virtual_network_subnet_ids = [
    module.private_endpoints_snet.id
  ]

  # private endpoint
  private_endpoint_name    = "${local.project}-cosmos-mongo-sql-endpoint"
  private_endpoint_enabled = true
  subnet_id                = module.private_endpoints_snet.id
  private_dns_zone_ids     = [data.azurerm_private_dns_zone.internal.id]

  tags = var.tags

}
```

### CosmosDB SQL version

```ts
module "cosmos_core" {
  source   = "git::https://github.com/pagopa/terraform-azurerm-v3.git//cosmosdb_account?ref=v8.8.0"
  name     = "${local.project}-cosmos-core"
  location = var.location
  domain   = var.domain

  resource_group_name = azurerm_resource_group.cosmos_rg[0].name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  main_geo_location_zone_redundant = false

  enable_free_tier          = false
  enable_automatic_failover = true

  consistency_policy = {
    consistency_level       = "Strong"
    max_interval_in_seconds = null
    max_staleness_prefix    = null
  }

  main_geo_location_location = "northeurope"

  additional_geo_locations = [
    {
      location          = "westeurope"
      failover_priority = 1
      zone_redundant    = false
    }
  ]

  backup_continuous_enabled = true

  is_virtual_network_filter_enabled = true

  ip_range = ""

  allowed_virtual_network_subnet_ids = [
    module.private_endpoints_snet.id
  ]

  # private endpoint
  private_endpoint_name    = "${local.project}-cosmos-core-sql-endpoint"
  private_endpoint_enabled = true
  subnet_id                = module.private_endpoints_snet.id
  private_dns_zone_ids     = [data.azurerm_private_dns_zone.internal.id]

  tags = var.tags

}
```


## Migration from v2

1️⃣ Arguments changed:

* The field `capabilities` will no longer accept the value `EnableAnalyticalStorage`.
* `primary_master_key` -> `primary_key`.
* `secondary_master_key` -> `secondary_key`.
* `primary_readonly_master_key` -> `primary_readonly_key`.
* `secondary_readonly_master_key` -> `secondary_readonly_key`.

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cosmosdb_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_monitor_metric_alert.cosmos_db_provisioned_throughput_exceeded](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_private_endpoint.cassandra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.mongo](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br/>    {<br/>      action_group_id    = string<br/>      webhook_properties = map(string)<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_additional_geo_locations"></a> [additional\_geo\_locations](#input\_additional\_geo\_locations) | Specifies a list of additional geo\_location resources, used to define where data should be replicated with the failover\_priority 0 specifying the primary location. | <pre>list(object({<br/>    location          = string # The name of the Azure region to host replicated data.<br/>    failover_priority = number # Required) The failover priority of the region. A failover priority of 0 indicates a write region. The maximum value for a failover priority = (total number of regions - 1). Failover priority values must be unique for each of the regions in which the database account exists. Changing this causes the location to be re-provisioned and cannot be changed for the location with failover priority 0.<br/>    zone_redundant    = bool   # Should zone redundancy be enabled for this region? Defaults to false.<br/>  }))</pre> | `[]` | no |
| <a name="input_allowed_virtual_network_subnet_ids"></a> [allowed\_virtual\_network\_subnet\_ids](#input\_allowed\_virtual\_network\_subnet\_ids) | The subnets id that are allowed to access this CosmosDB account. | `list(string)` | `[]` | no |
| <a name="input_backup_continuous_enabled"></a> [backup\_continuous\_enabled](#input\_backup\_continuous\_enabled) | Enable Continuous Backup | `bool` | `true` | no |
| <a name="input_backup_periodic_enabled"></a> [backup\_periodic\_enabled](#input\_backup\_periodic\_enabled) | Enable Periodic Backup | <pre>object({<br/>    interval_in_minutes = string<br/>    retention_in_hours  = string<br/>    storage_redundancy  = string<br/>  })</pre> | `null` | no |
| <a name="input_burst_capacity_enabled"></a> [burst\_capacity\_enabled](#input\_burst\_capacity\_enabled) | (Optional) Enable burst capacity for this Cosmos DB account. Defaults to false. | `bool` | `false` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | The capabilities which should be enabled for this Cosmos DB account. | `list(string)` | `[]` | no |
| <a name="input_consistency_policy"></a> [consistency\_policy](#input\_consistency\_policy) | Specifies a consistency\_policy resource, used to define the consistency policy for this CosmosDB account. | <pre>object({<br/>    consistency_level       = string # The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix.<br/>    max_interval_in_seconds = number # When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day). Defaults to 5. Required when consistency_level is set to BoundedStaleness.<br/>    max_staleness_prefix    = number # When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 – 2147483647. Defaults to 100. Required when consistency_level is set to BoundedStaleness.<br/>  })</pre> | <pre>{<br/>  "consistency_level": "BoundedStaleness",<br/>  "max_interval_in_seconds": 5,<br/>  "max_staleness_prefix": 100<br/>}</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | (Optional) Specifies the domain of the CosmosDB Account. | `string` | n/a | yes |
| <a name="input_enable_automatic_failover"></a> [enable\_automatic\_failover](#input\_enable\_automatic\_failover) | Enable automatic fail over for this Cosmos DB account. | `bool` | `true` | no |
| <a name="input_enable_free_tier"></a> [enable\_free\_tier](#input\_enable\_free\_tier) | Enable Free Tier pricing option for this Cosmos DB account. Defaults to false. Changing this forces a new resource to be created. | `bool` | `true` | no |
| <a name="input_enable_multiple_write_locations"></a> [enable\_multiple\_write\_locations](#input\_enable\_multiple\_write\_locations) | Enable multi-master support for this Cosmos DB account. | `bool` | `false` | no |
| <a name="input_enable_provisioned_throughput_exceeded_alert"></a> [enable\_provisioned\_throughput\_exceeded\_alert](#input\_enable\_provisioned\_throughput\_exceeded\_alert) | Enable the Provisioned Throughput Exceeded alert. Default is true | `bool` | `true` | no |
| <a name="input_ip_range"></a> [ip\_range](#input\_ip\_range) | The set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IP's for a given database account. | `string` | `null` | no |
| <a name="input_is_virtual_network_filter_enabled"></a> [is\_virtual\_network\_filter\_enabled](#input\_is\_virtual\_network\_filter\_enabled) | Enables virtual network filtering for this Cosmos DB account. | `bool` | `true` | no |
| <a name="input_key_vault_key_id"></a> [key\_vault\_key\_id](#input\_key\_vault\_key\_id) | (Optional) A versionless Key Vault Key ID for CMK encryption. Changing this forces a new resource to be created. When referencing an azurerm\_key\_vault\_key resource, use versionless\_id instead of id | `string` | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_main_geo_location_location"></a> [main\_geo\_location\_location](#input\_main\_geo\_location\_location) | (Required) The name of the Azure region to host replicated data. | `string` | n/a | yes |
| <a name="input_main_geo_location_zone_redundant"></a> [main\_geo\_location\_zone\_redundant](#input\_main\_geo\_location\_zone\_redundant) | Should zone redundancy be enabled for main region? Set true for prod environments | `bool` | n/a | yes |
| <a name="input_minimal_tls_version"></a> [minimal\_tls\_version](#input\_minimal\_tls\_version) | (Optional) Specifies the minimal TLS version for the CosmosDB account. Possible values are: Tls, Tls11, and Tls12. Defaults to Tls12. | `string` | `"Tls12"` | no |
| <a name="input_mongo_server_version"></a> [mongo\_server\_version](#input\_mongo\_server\_version) | The Server Version of a MongoDB account. Possible values are 4.0, 3.6, and 3.2. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Specifies the name of the CosmosDB Account. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_offer_type"></a> [offer\_type](#input\_offer\_type) | The CosmosDB account offer type. At the moment can only be set to Standard | `string` | `"Standard"` | no |
| <a name="input_private_dns_zone_cassandra_ids"></a> [private\_dns\_zone\_cassandra\_ids](#input\_private\_dns\_zone\_cassandra\_ids) | Used only for private endpoints | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_mongo_ids"></a> [private\_dns\_zone\_mongo\_ids](#input\_private\_dns\_zone\_mongo\_ids) | Used only for private endpoints | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_sql_ids"></a> [private\_dns\_zone\_sql\_ids](#input\_private\_dns\_zone\_sql\_ids) | Used only for private endpoints | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_table_ids"></a> [private\_dns\_zone\_table\_ids](#input\_private\_dns\_zone\_table\_ids) | Used only for private endpoints | `list(string)` | `[]` | no |
| <a name="input_private_endpoint_cassandra_name"></a> [private\_endpoint\_cassandra\_name](#input\_private\_endpoint\_cassandra\_name) | Private endpoint name. If null it will assume the cosmosdb account name. | `string` | `null` | no |
| <a name="input_private_endpoint_enabled"></a> [private\_endpoint\_enabled](#input\_private\_endpoint\_enabled) | Enable private endpoint | `bool` | `true` | no |
| <a name="input_private_endpoint_mongo_name"></a> [private\_endpoint\_mongo\_name](#input\_private\_endpoint\_mongo\_name) | Private endpoint name. If null it will assume the cosmosdb account name. | `string` | `null` | no |
| <a name="input_private_endpoint_sql_name"></a> [private\_endpoint\_sql\_name](#input\_private\_endpoint\_sql\_name) | Private endpoint name. If null it will assume the cosmosdb account name. | `string` | `null` | no |
| <a name="input_private_endpoint_table_name"></a> [private\_endpoint\_table\_name](#input\_private\_endpoint\_table\_name) | Private endpoint name. If null it will assume the cosmosdb account name. | `string` | `null` | no |
| <a name="input_private_service_connection_cassandra_name"></a> [private\_service\_connection\_cassandra\_name](#input\_private\_service\_connection\_cassandra\_name) | Private service connection name. If null, it will assume the cosmos db account name | `string` | `null` | no |
| <a name="input_private_service_connection_mongo_name"></a> [private\_service\_connection\_mongo\_name](#input\_private\_service\_connection\_mongo\_name) | Private service connection name. If null, it will assume the cosmos db account name | `string` | `null` | no |
| <a name="input_private_service_connection_sql_name"></a> [private\_service\_connection\_sql\_name](#input\_private\_service\_connection\_sql\_name) | Private service connection name. If null, it will assume the cosmos db account name | `string` | `null` | no |
| <a name="input_provisioned_throughput_exceeded_threshold"></a> [provisioned\_throughput\_exceeded\_threshold](#input\_provisioned\_throughput\_exceeded\_threshold) | The Provisioned Throughput Exceeded threshold. If metric average is over this value, the alert will be triggered. Default is 0, we want to act as soon as possible. | `number` | `0` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether or not public network access is allowed for this CosmosDB account | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which the CosmosDB Account is created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Used only for private endpoints | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_strings"></a> [connection\_strings](#output\_connection\_strings) | n/a |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The endpoint used to connect to the CosmosDB account. |
| <a name="output_id"></a> [id](#output\_id) | The id of the CosmosDB account. |
| <a name="output_name"></a> [name](#output\_name) | The name of the CosmosDB created. |
| <a name="output_primary_key"></a> [primary\_key](#output\_primary\_key) | n/a |
| <a name="output_primary_master_key"></a> [primary\_master\_key](#output\_primary\_master\_key) | @deprecated |
| <a name="output_primary_readonly_key"></a> [primary\_readonly\_key](#output\_primary\_readonly\_key) | n/a |
| <a name="output_primary_readonly_master_key"></a> [primary\_readonly\_master\_key](#output\_primary\_readonly\_master\_key) | @deprecated |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | n/a |
| <a name="output_read_endpoints"></a> [read\_endpoints](#output\_read\_endpoints) | A list of read endpoints available for this CosmosDB account. |
| <a name="output_secondary_key"></a> [secondary\_key](#output\_secondary\_key) | n/a |
| <a name="output_write_endpoints"></a> [write\_endpoints](#output\_write\_endpoints) | A list of write endpoints available for this CosmosDB account. |
<!-- END_TF_DOCS -->

# Cosmos DB sql database

This module allow the setup of a cosmos db sql database

## Architecture

![This is an image](./docs/module-arch.drawio.png)

## How to use

### CosmosDB database (MongoDB version)

```ts
resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = "mongoDB"
  resource_group_name = azurerm_resource_group.cosmos_mongo_rg[0].name
  account_name        = module.cosmos_mongo.name

  throughput = null

  dynamic "autoscale_settings" {
    for_each = []
    content {
      max_throughput = 100
    }
  }

  lifecycle {
    ignore_changes = [
      autoscale_settings
    ]
  }
}
```

### CosmosDB database (SQL version)

```ts
## Database
module "core_cosmos_db" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//cosmosdb_sql_database?ref=v3.15.0"
  name                = "db"
  resource_group_name = azurerm_resource_group.cosmos_rg[0].name
  account_name        = module.cosmos_core.name
}
```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.71.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cosmosdb_sql_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | The name of the Cosmos DB SQL Database to create the table within. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Cosmos DB SQL Database | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the Cosmos DB SQL Database is created. | `string` | n/a | yes |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | The throughput of SQL database (RU/s). | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

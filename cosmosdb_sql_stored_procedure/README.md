# Cosmos DB sql Stored Procedure

This module allow the setup of a cosmos db sql container stored procedure

## How to use

```ts
resource "azurerm_cosmosdb_sql_stored_procedure" "stored_procedure" {
  name                = var.name
  resource_group_name = var.resource_group_name
  account_name        = var.account_name
  database_name       = var.database_name
  container_name      = var.container_name
  body = var.body
}

```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cosmosdb_sql_stored_procedure.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_stored_procedure) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | The name of the Cosmos DB SQL Database to create the table within. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Cosmos DB SQL Database | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the Cosmos DB SQL Database is created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

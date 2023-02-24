# Storage object replication

This module allows the creation of resource: `azurerm_storage_object_replication`

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.45.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.44.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_object_replication.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_object_replication) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_storage_account_id"></a> [destination\_storage\_account\_id](#input\_destination\_storage\_account\_id) | The ID of the destination storage account. | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | n/a | <pre>list(<br>    object({<br>      source_container_name      = string<br>      destination_container_name = string<br>      copy_blobs_created_after   = string<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_source_storage_account_id"></a> [source\_storage\_account\_id](#input\_source\_storage\_account\_id) | The ID of the source storage account. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

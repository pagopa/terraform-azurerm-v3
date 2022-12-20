<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.36.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_rules"></a> [rules](#input\_rules) | n/a | <pre>list(object({<br>    name    = string<br>    enabled = bool<br>    filters = object({<br>      prefix_match = list(string)<br>      blob_types   = list(string)<br>    })<br>    actions = object({<br>      snapshot = object({<br>        delete_after_days_since_creation_greater_than = number<br>      })<br>      base_blob = object({<br>        tier_to_cool_after_days_since_modification_greater_than    = number<br>        tier_to_archive_after_days_since_modification_greater_than = number<br>        delete_after_days_since_modification_greater_than          = number<br>      })<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Specifies the id of the storage account to apply the management policy to. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

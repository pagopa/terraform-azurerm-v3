# Storage management policy

This module allow the creation of a management policy for storage account

## How to use

```ts
module "storage_account_durable_function_management_policy" {
  count  = length(local.internal_containers) == 0 ? 0 : 1
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//storage_management_policy?ref=v8.8.0"

  storage_account_id = module.storage_account_durable_function[0].id

  rules = [
    {
      name    = "deleteafterdays"
      enabled = true
      filters = {
        prefix_match = local.internal_containers
        blob_types   = ["blockBlob"]
      }
      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 0
          tier_to_archive_after_days_since_modification_greater_than = 0
          delete_after_days_since_modification_greater_than          = var.internal_storage.blobs_retention_days
        }
        snapshot = null
      }
    },
  ]
}
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
| [azurerm_storage_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_rules"></a> [rules](#input\_rules) | n/a | <pre>list(object({<br>    name    = string<br>    enabled = bool<br>    filters = object({<br>      prefix_match = list(string) # (Optional) An array of strings for prefixes to be matched.<br>      blob_types   = list(string) # (Required) An array of predefined values. Valid options are blockBlob and appendBlob.<br>    })<br>    actions = object({<br>      base_blob = object({<br>        delete_after_days_since_modification_greater_than              = optional(number, null)<br>        delete_after_days_since_creation_greater_than                  = optional(number, null)<br>        delete_after_days_since_last_access_time_greater_than          = optional(number, null)<br>        tier_to_cool_after_days_since_modification_greater_than        = optional(number, null)<br>        tier_to_cool_after_days_since_creation_greater_than            = optional(number, null)<br>        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number, null)<br>        tier_to_archive_after_days_since_modification_greater_than     = optional(number, null)<br>        tier_to_archive_after_days_since_creation_greater_than         = optional(number, null)<br>        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number, null)<br>        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null)<br>      })<br>      snapshot = optional(object({<br>        change_tier_to_archive_after_days_since_creation               = optional(number, null)<br>        change_tier_to_cool_after_days_since_creation                  = optional(number, null)<br>        delete_after_days_since_creation_greater_than                  = optional(number, null)<br>        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null)<br>      }), null)<br>      version = optional(object({<br>        change_tier_to_archive_after_days_since_creation               = optional(number, null)<br>        change_tier_to_cool_after_days_since_creation                  = optional(number, null)<br>        delete_after_days_since_creation                               = optional(number, null)<br>        tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number, null)<br>      }), null)<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Specifies the id of the storage account to apply the management policy to. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

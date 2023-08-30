# kubernetes_cluster_velero

This module installs Velero on the configured aks cluster, and optionally schedules the backup for all the namespaces



## How to use it

```hcl
  resource "azurerm_resource_group" "rg_velero_backup" {
    name     = local.aks_rg_name
    location = var.location
    tags     = var.tags
  }

  # required for velero backups
  module "velero_storage_account" {
    source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//storage_account?ref=v7.2.0"
  
    name = "${var.prefix}velerosa"
    account_kind                    = "BlobStorage"
    account_tier                    = "Standard"
    account_replication_type        = "LRS"
    blob_versioning_enabled         = true
    resource_group_name             = azurerm_resource_group.rg_velero_backup.name
    location                        = var.location
    allow_nested_items_to_be_public = true
    advanced_threat_protection      = true
    enable_low_availability_alert   = false
    public_network_access_enabled   = true
    tags                            = var.tags
  }

  module "velero" {
    source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_cluster_velero?ref=<version>"
    
    backup_enabled = false
    backup_storage_account_name = module.velero_storage_account.name
    backup_storage_container_name = "velero-backup"
    resource_group_name = azurerm_resource_group.rg_velero_backup.name
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id = data.azurerm_subscription.current.tenant_id
    backup_ttl = "2h0m0s"
    backup_schedule = "0 12 * * *"

    tags = var.tags
  }


```


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
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.41.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.53.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.velero_application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.velero_application_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.velero_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_password.velero_principal_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_password) | resource |
| [azurerm_role_assignment.velero_sp_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_container.velero_backup_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [local_file.credentials](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.install_velero](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.schedule_backup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_storage_account.velero_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_prefix"></a> [application\_prefix](#input\_application\_prefix) | (Optional) Prefix used in the AD Application name, if provided | `string` | `null` | no |
| <a name="input_backup_enabled"></a> [backup\_enabled](#input\_backup\_enabled) | (Optional) Enables the scheduled Velero backups of all the namespaces | `bool` | `false` | no |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | (Optional) Cron expression for the scheduled velero backup including all namespaces, in UTC timezone. ref: https://velero.io/docs/v1.9/backup-reference/ | `string` | `"0 3 * * *"` | no |
| <a name="input_backup_storage_account_name"></a> [backup\_storage\_account\_name](#input\_backup\_storage\_account\_name) | (Required) Name of the storage account where Velero keeps the backups | `string` | n/a | yes |
| <a name="input_backup_storage_container_name"></a> [backup\_storage\_container\_name](#input\_backup\_storage\_container\_name) | (Required) Name of the storage container where Velero keeps the backups | `string` | n/a | yes |
| <a name="input_backup_ttl"></a> [backup\_ttl](#input\_backup\_ttl) | (Optional) TTL for velero 'all namespaces' backup, expressed using '<number>h<number>m<number>s' format | `string` | `"360h0m0s"` | no |
| <a name="input_plugin_version"></a> [plugin\_version](#input\_plugin\_version) | (Optional) Version for the velero plugin | `string` | `"v1.5.0"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Name of the resource group in which the backup storage account is located | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) ID of the subscriiption | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | (Required) ID of the tenant | `string` | n/a | yes |
| <a name="input_volume_snapshot"></a> [volume\_snapshot](#input\_volume\_snapshot) | (Optional) Whether or not to execute the persistence volume snapshot. Disabled by default | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

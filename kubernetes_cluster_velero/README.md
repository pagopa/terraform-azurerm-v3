# kubernetes_cluster_velero

This module installs Velero on the configured aks cluster
Note that this module selects the correct cluster to work on using the command `kubectl config use-context "<cluster_name>"`, so you should have that context available in your `.kube` folder.
This is achievable using the utility script `k8setup.sh` included in the aks-setup folder of your IaC project


## How to use it

```hcl
  resource "azurerm_resource_group" "rg_velero_backup" {
    name     = local.aks_rg_name
    location = var.location
    tags     = var.tags
  }
 
  module "velero" {
    source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_cluster_velero?ref=<version>"
    
    # required
    backup_storage_container_name = "velero-backup"
    resource_group_name = azurerm_resource_group.rg_velero_backup.name
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id = data.azurerm_subscription.current.tenant_id
    prefix = "my-app"
    location = var.location
    aks_cluster_name = module.aks.name
    aks_cluster_rg = azurerm_resource_group.rg_aks.name
    
    # optional
    plugin_version = "v1.7.1"
    use_storage_private_endpoint = true
    
    enable_sa_backup = var.velero_sa_backup_enabled
    sa_backup_retention_days = var.velero_sa_backup_retention_days
    
    
    # required if use_storage_private_endpoint = true
    storage_account_private_dns_zone_id = azurerm_private_dns_zone.storage_account.id
    private_endpoint_subnet_id = module.private_endpoint_snet.id

    tags = var.tags
  }


```


<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.94.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_velero_storage_account"></a> [velero\_storage\_account](#module\_velero\_storage\_account) | github.com/pagopa/terraform-azurerm-v3.git//storage_account | v7.64.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_application.velero_application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.velero_application_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.velero_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_password.velero_principal_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_password) | resource |
| [azurerm_private_endpoint.velero_storage_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.velero_sp_aks_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.velero_sp_storage_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_container.velero_backup_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [local_file.credentials](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.install_velero](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_kubernetes_cluster.aks_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | (Required) Name of the aks cluster on which Velero will be installed | `string` | n/a | yes |
| <a name="input_aks_cluster_rg"></a> [aks\_cluster\_rg](#input\_aks\_cluster\_rg) | (Required) AKS cluster resource group name | `string` | n/a | yes |
| <a name="input_backup_storage_container_name"></a> [backup\_storage\_container\_name](#input\_backup\_storage\_container\_name) | (Required) Name of the storage container where Velero keeps the backups | `string` | n/a | yes |
| <a name="input_enable_sa_backup"></a> [enable\_sa\_backup](#input\_enable\_sa\_backup) | (Optional) enables storage account point in time recovery | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Resource location | `string` | n/a | yes |
| <a name="input_plugin_version"></a> [plugin\_version](#input\_plugin\_version) | (Optional) Version for the velero plugin | `string` | `"v1.7.1"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix used in the Velero dedicated resource names | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | (Optional) Subnet id where to create the private endpoint for backups storage account | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Name of the resource group in which the backup storage account is located | `string` | n/a | yes |
| <a name="input_sa_backup_retention_days"></a> [sa\_backup\_retention\_days](#input\_sa\_backup\_retention\_days) | (Optional) number of days for which the storage account is available for point in time recovery | `number` | `0` | no |
| <a name="input_storage_account_kind"></a> [storage\_account\_kind](#input\_storage\_account\_kind) | (Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2 | `string` | `"StorageV2"` | no |
| <a name="input_storage_account_private_dns_zone_id"></a> [storage\_account\_private\_dns\_zone\_id](#input\_storage\_account\_private\_dns\_zone\_id) | (Optional) Storage account private dns zone id, used in the private endpoint creation | `string` | `null` | no |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | (Optional) Replication type used for the backup storage account | `string` | `"ZRS"` | no |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | (Optional) Tier used for the backup storage account | `string` | `"Standard"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) ID of the subscription | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | (Required) ID of the tenant | `string` | n/a | yes |
| <a name="input_use_storage_private_endpoint"></a> [use\_storage\_private\_endpoint](#input\_use\_storage\_private\_endpoint) | (Optional) Whether to make the storage account private and use a private endpoint to connect | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

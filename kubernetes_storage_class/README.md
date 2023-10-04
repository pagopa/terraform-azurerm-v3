# kubernetes storage class

This module creates a series of storage class with ZRS redundancy to be used in place of the default ones provided by AKS


## How to use it

```hcl
module "aks_storage_class" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_storage_class?ref=<version>"
  
  aks_cluster_name = "my-cluster-name"
}
```


<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.71.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_storage_class_v1.azurefile_csi_premium_zrs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.azurefile_csi_zrs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.azurefile_premium_zrs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.azurefile_zrs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.default_zrs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.managed_csi_premium_zrs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.managed_csi_zrs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.managed_zrs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.standard_hdd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | (Required) Cluster name where these storage classes will be created | `string` | n/a | yes |
| <a name="input_k8s_kube_config_path_prefix"></a> [k8s\_kube\_config\_path\_prefix](#input\_k8s\_kube\_config\_path\_prefix) | (Optional) Path to kube config files | `string` | `"~/.kube"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurefile_csi_premium_zrs"></a> [azurefile\_csi\_premium\_zrs](#output\_azurefile\_csi\_premium\_zrs) | Azurefile CSI premium disk with ZRS storage class name |
| <a name="output_azurefile_csi_zrs"></a> [azurefile\_csi\_zrs](#output\_azurefile\_csi\_zrs) | Azurefile CSI with ZRS storage class name |
| <a name="output_azurefile_premium_zrs"></a> [azurefile\_premium\_zrs](#output\_azurefile\_premium\_zrs) | Azurefile premium with ZRS storage class name |
| <a name="output_azurefile_zrs"></a> [azurefile\_zrs](#output\_azurefile\_zrs) | Azurefile with ZRS storage class name |
| <a name="output_default_zrs"></a> [default\_zrs](#output\_default\_zrs) | Default with ZRS storage class name |
| <a name="output_managed_csi_premium_zrs"></a> [managed\_csi\_premium\_zrs](#output\_managed\_csi\_premium\_zrs) | Managed CSI  premium with ZRS storage class name |
| <a name="output_managed_csi_zrs"></a> [managed\_csi\_zrs](#output\_managed\_csi\_zrs) | Managed CSI with ZRS storage class name |
| <a name="output_managed_zrs"></a> [managed\_zrs](#output\_managed\_zrs) | Managed with ZRS storage class name |
| <a name="output_standard_hdd"></a> [standard\_hdd](#output\_standard\_hdd) | Standard HDD storage class name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# kubernetes storage class

This module creates a series of storage class with ZRS redundancy to be used in place of the default ones provided by AKS

## List of storageclasses

* "standard-hdd"
* "azurefile-zrs"
* "azurefile-csi-zrs"
* "azurefile-csi-premium-zrs"
* "azurefile-premium-zrs"
* "default-zrs"
* "managed-zrs"
* "managed-csi-zrs"
* "managed-csi-premium-zrs"

## How to use it

```hcl
module "aks_storage_class" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_storage_class?ref=v8.8.0"
  
}
```

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.27 |

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

No inputs.

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
<!-- END_TF_DOCS -->

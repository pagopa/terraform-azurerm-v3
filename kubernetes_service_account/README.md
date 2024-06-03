# kubernetes service account

This module creates a service account and its related secrets



## How to use it

```hcl
module "kubernetes_service_account" {
  source  = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_service_account?ref=v8.8.0"
  name = "azure-devops"
  namespace = local.system_domain_namespace
}
```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| [kubernetes_secret_v1.azure_devops_service_account_default_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_account.azure_devops](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_secret.azure_devops_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_service_account_default_secret_name"></a> [custom\_service\_account\_default\_secret\_name](#input\_custom\_service\_account\_default\_secret\_name) | Service account custom secret name | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Service account name | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Service account namespace | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sa_ca_cert"></a> [sa\_ca\_cert](#output\_sa\_ca\_cert) | n/a |
| <a name="output_sa_token"></a> [sa\_token](#output\_sa\_token) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

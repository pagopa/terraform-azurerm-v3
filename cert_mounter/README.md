# Cert mounter

This module deploys the cert mounter blueprint in the target namespace, creating a secret for the certificate which is retrieved from the key vault given in input

## How to use

```hcl

module "cert_mounter" {
  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//cert_mounter?ref=<version>"
  namespace           = var.domain
  certificate_name    = "${var.aks_cluster_domain_name}-${var.domain}-internal-${var.env}-cstar-pagopa-it" #name of the certificate stored in the given kv
  kv_name             = data.azurerm_key_vault.kv.name
  tenant_id           = data.azurerm_subscription.current.tenant_id
}

```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.5.1, <= 2.7.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cert_mounter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_name"></a> [certificate\_name](#input\_certificate\_name) | (Required) Name of the certificate stored in the keyvault, that will be installed as a secret in aks | `string` | n/a | yes |
| <a name="input_kv_name"></a> [kv\_name](#input\_kv\_name) | (Required) Key vault name where to retrieve the certificate | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | (Required) Namespace where the cert secret will be created | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | (Required) Tenant identifier | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

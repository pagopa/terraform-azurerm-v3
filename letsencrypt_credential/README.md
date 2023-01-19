# Let's Encrypt account

This module allow the creation of an let's encrypt credentials

## Architecture

TBD

## Configurations

### Mandatory configurations

## How to use it

```ts
module "letsencrypt_diego" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//letsencrypt_credential?ref=v3.15.0"

  prefix            = "dvopla"
  env               = "d"
  key_vault_name    = "dvopla-d-diego-kv"
  subscription_name = "devopslab"
}
```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.38.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.this](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certbot_version"></a> [certbot\_version](#input\_certbot\_version) | certbot version from https://hub.docker.com/r/certbot/certbot/tags | `string` | `"v1.29.0@sha256:904fd574583ed30b2ebd3e17a4ab953a69589e0d4860c3199d117ad1dd7a4e94"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment | `string` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Key vault where save Let's encrypt credentials | `string` | n/a | yes |
| <a name="input_le_email"></a> [le\_email](#input\_le\_email) | Let's encrypt email account | `string` | `"letsencrypt-bots@pagopa.it"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Project prefix | `string` | n/a | yes |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | Azure subscription name where key vault is located | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

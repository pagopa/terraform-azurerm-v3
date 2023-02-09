# jwt_keys

Module that allows the creation of an jwt keys.

## How to use it

```ts
module "my_jwt" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//jwt_keys?ref=v3.4.1"

  jwt_name         = "my-jwt"
  key_vault_id     = azurerm_key_vault.kv.id
  cert_common_name = "My Common Name"
  cert_password    = ""
  tags             = var.tags
}
```

## Migration from v2

Nothing to change

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.40.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | <= 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.40.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.jwt_cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.jwt_kid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.jwt_private_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.jwt_public_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [tls_private_key.jwt](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.jwt_self](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_common_name"></a> [cert\_common\_name](#input\_cert\_common\_name) | cert info | `string` | n/a | yes |
| <a name="input_cert_country"></a> [cert\_country](#input\_cert\_country) | n/a | `string` | `""` | no |
| <a name="input_cert_locality"></a> [cert\_locality](#input\_cert\_locality) | n/a | `string` | `""` | no |
| <a name="input_cert_organization"></a> [cert\_organization](#input\_cert\_organization) | n/a | `string` | `""` | no |
| <a name="input_cert_organizational_unit"></a> [cert\_organizational\_unit](#input\_cert\_organizational\_unit) | n/a | `string` | `""` | no |
| <a name="input_cert_password"></a> [cert\_password](#input\_cert\_password) | n/a | `string` | n/a | yes |
| <a name="input_cert_postal_code"></a> [cert\_postal\_code](#input\_cert\_postal\_code) | n/a | `string` | `""` | no |
| <a name="input_cert_province"></a> [cert\_province](#input\_cert\_province) | n/a | `string` | `""` | no |
| <a name="input_cert_serial_number"></a> [cert\_serial\_number](#input\_cert\_serial\_number) | n/a | `string` | `""` | no |
| <a name="input_cert_street_address"></a> [cert\_street\_address](#input\_cert\_street\_address) | n/a | `list(string)` | `[]` | no |
| <a name="input_cert_validity_hours"></a> [cert\_validity\_hours](#input\_cert\_validity\_hours) | n/a | `number` | `8640` | no |
| <a name="input_early_renewal_hours"></a> [early\_renewal\_hours](#input\_early\_renewal\_hours) | n/a | `number` | `720` | no |
| <a name="input_jwt_name"></a> [jwt\_name](#input\_jwt\_name) | n/a | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_data_pem"></a> [certificate\_data\_pem](#output\_certificate\_data\_pem) | n/a |
| <a name="output_jwt_kid"></a> [jwt\_kid](#output\_jwt\_kid) | n/a |
| <a name="output_jwt_private_key_pem"></a> [jwt\_private\_key\_pem](#output\_jwt\_private\_key\_pem) | n/a |
| <a name="output_jwt_public_key_pem"></a> [jwt\_public\_key\_pem](#output\_jwt\_public\_key\_pem) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

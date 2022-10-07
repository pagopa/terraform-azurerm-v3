<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.20.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | <= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.24.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.4.0 |

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
| <a name="input_cert_password"></a> [cert\_password](#input\_cert\_password) | n/a | `string` | n/a | yes |
| <a name="input_cert_validity_hours"></a> [cert\_validity\_hours](#input\_cert\_validity\_hours) | n/a | `number` | `8640` | no |
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

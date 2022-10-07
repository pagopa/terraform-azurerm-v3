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
| [azurerm_linux_virtual_machine.jumpbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.vm_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.sg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.vm_sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.vm_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [tls_private_key.ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Jumpbox VM user name | `string` | `"azureuser"` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | Specifies the version of the image used to create the virtual machines. | `string` | `"latest"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_offer"></a> [offer](#input\_offer) | Specifies the offer of the image used to create the virtual machines. | `string` | `"UbuntuServer"` | no |
| <a name="input_pip_allocation_method"></a> [pip\_allocation\_method](#input\_pip\_allocation\_method) | Public IP allocation method. | `string` | `"Dynamic"` | no |
| <a name="input_publisher"></a> [publisher](#input\_publisher) | Specifies the Publisher of the Marketplace Image this Virtual Machine should be created from. | `string` | `"Canonical"` | no |
| <a name="input_remote_exec_inline_commands"></a> [remote\_exec\_inline\_commands](#input\_remote\_exec\_inline\_commands) | List of bash command executed remotely when the vm is created. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_size"></a> [size](#input\_size) | The SKU which should be used for this Virtual Machine, | `string` | `"Standard_DS1_v2"` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Specifies the SKU of the image used to create the virtual machines. | `string` | `"16.04-LTS"` | no |
| <a name="input_source_address_prefix"></a> [source\_address\_prefix](#input\_source\_address\_prefix) | CIDR or source IP range or * to match any IP. ue | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of subnet where jumpbox VM will be installed | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip"></a> [ip](#output\_ip) | Jumpbox VM IP |
| <a name="output_tls_private_key"></a> [tls\_private\_key](#output\_tls\_private\_key) | n/a |
| <a name="output_username"></a> [username](#output\_username) | Jumpbox VM username |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

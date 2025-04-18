<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.custom_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.custom_security_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_security_group"></a> [custom\_security\_group](#input\_custom\_security\_group) | security groups configuration | <pre>map(object({<br/>    target_subnet_name                    = string<br/>    target_subnet_vnet_name               = string<br/>    target_application_security_group_ids = optional(list(string))<br/>    inbound_rules = list(object({<br/>      name                                  = string<br/>      priority                              = number<br/>      access                                = string<br/>      protocol                              = string<br/>      source_subnet_name                    = string<br/>      source_subnet_vnet_name               = string<br/>      source_application_security_group_ids = optional(list(string))<br/>      source_port_ranges                    = optional(list(string), ["*"])<br/>      source_address_prefix                 = optional(string)<br/>      source_address_prefixes               = optional(list(string))<br/>      destination_address_prefixes          = optional(list(string))<br/>      destination_port_ranges               = optional(list(string), ["*"])<br/>      description                           = optional(string) // todo validation 140 caratteri<br/>    }))<br/><br/>    outbound_rules = list(object({<br/>      name                                       = string<br/>      priority                                   = number<br/>      access                                     = string<br/>      protocol                                   = string<br/>      source_address_prefixes                    = optional(list(string))<br/>      source_port_ranges                         = optional(list(string), ["*"])<br/>      destination_subnet_name                    = string<br/>      destination_subnet_vnet_name               = string<br/>      destination_application_security_group_ids = optional(list(string))<br/>      destination_port_ranges                    = optional(list(string), ["*"])<br/>      destination_address_prefix                 = optional(string)<br/>      destination_address_prefixes               = optional(list(string))<br/>      description                                = optional(string) // todo validation 140 caratteri<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_default_security_group"></a> [default\_security\_group](#input\_default\_security\_group) | n/a | <pre>map(object({<br/>    type = string //todo validate on available types<br/><br/>    source_subnet_name      = string<br/>    source_subnet_vnet_name = string<br/><br/>    destination_subnet_name      = string<br/>    destination_subnet_vnet_name = string<br/>  }))</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the resource group where the nsg will be saved | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resources | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the nsg will be saved | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to the nsg | `map(string)` | n/a | yes |
| <a name="input_vnets"></a> [vnets](#input\_vnets) | n/a | <pre>list(object({<br/>    name    = string<br/>    rg_name = string<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

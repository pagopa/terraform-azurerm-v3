# subnet

This module allow the creation of subnet

## How to use it

### Simple subnet

```ts
module "private_endpoints_snet" {
  source               = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v3.15.0"
  name                 = "${local.program}-private-endpoints-snet"
  address_prefixes     = var.cidr_subnet_private_endpoints
  virtual_network_name = data.azurerm_virtual_network.vnet.name

  resource_group_name = data.azurerm_resource_group.rg_vnet.name

  private_endpoint_network_policies_enabled = true
  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.AzureCosmosDB",
    "Microsoft.Storage",
  ]
}
```

### Subnet with delegation

```ts
module "funcs_diego_snet" {
  source                                    = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v3.15.0"
  name                                      = "${local.project}-funcs-snet"
  address_prefixes                          = var.cidr_subnet_funcs_diego_domain
  resource_group_name                       = data.azurerm_resource_group.rg_vnet_core.name
  virtual_network_name                      = data.azurerm_virtual_network.vnet_core.name
  
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.AzureCosmosDB",
    "Microsoft.Storage",
  ]

  delegation = {
    name = "default"
    service_delegation = {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
```

## Migration from v2

🆕 Output attributes changed (compatibility broken):

* `addres_prefix` -> `address_prefixes`
* `enforce_private_link_endpoint_network_policies` -> `private_endpoint_network_policies_enabled`
* `enforce_private_link_service_network_policies` -> `private_link_service_network_policies_enabled`

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.45.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.30.0, <= 3.45.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefixes"></a> [address\_prefixes](#input\_address\_prefixes) | (Optional) The address prefixes to use for the subnet. (e.g. ['10.1.137.0/24']) | `list(string)` | `[]` | no |
| <a name="input_delegation"></a> [delegation](#input\_delegation) | n/a | <pre>object({<br>    name = string #(Required) A name for this delegation.<br>    service_delegation = object({<br>      name    = string       #(Required) The name of service to delegate to. Possible values are https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet#service_delegation<br>      actions = list(string) #(Optional) A list of Actions which should be delegated. Here the list: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet#actions<br>    })<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint_network_policies_enabled"></a> [private\_endpoint\_network\_policies\_enabled](#input\_private\_endpoint\_network\_policies\_enabled) | (Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true. | `bool` | `false` | no |
| <a name="input_private_link_service_network_policies_enabled"></a> [private\_link\_service\_network\_policies\_enabled](#input\_private\_link\_service\_network\_policies\_enabled) | (Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | (Optional) The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web. | `list(string)` | `[]` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_prefixes"></a> [address\_prefixes](#output\_address\_prefixes) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

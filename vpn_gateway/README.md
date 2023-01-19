# VPN Gateway

This module allow the creation of vpn gateway

## How to use

```ts
## VPN subnet
module "vpn_snet" {
  source                                    = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v3.15.0"
  name                                      = "GatewaySubnet"
  address_prefixes                          = var.cidr_subnet_vpn
  virtual_network_name                      = module.vnet.name
  resource_group_name                       = azurerm_resource_group.rg_vnet.name
  service_endpoints                         = []
  private_endpoint_network_policies_enabled = true
}

data "azuread_application" "vpn_app" {
  display_name = "${local.project}-app-vpn"
}

module "vpn" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//vpn_gateway?ref=v3.15.0"

  name                = "${local.project}-vpn"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  sku                 = var.vpn_sku
  pip_sku             = var.vpn_pip_sku
  subnet_id           = module.vpn_snet.id

  vpn_client_configuration = [
    {
      address_space         = ["172.16.1.0/24"],
      vpn_client_protocols  = ["OpenVPN"],
      aad_audience          = data.azuread_application.vpn_app.application_id
      aad_issuer            = "https://sts.windows.net/${data.azurerm_subscription.current.tenant_id}/"
      aad_tenant            = "https://login.microsoftonline.com/${data.azurerm_subscription.current.tenant_id}"
      radius_server_address = null
      radius_server_secret  = null
      revoked_certificate   = []
      root_certificate      = []
    }
  ]

  tags = var.tags
}
```

## Migration from v2

Due to drift problems with some fields in the state is possible that you need to delete the state associated to this resource a re-import

```sh
terraform state rm module.vpn.azurerm_virtual_network_gateway.gw
```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.38.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | <= 3.4.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.38.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_local_network_gateway.local](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_monitor_diagnostic_setting.gw_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.sec_gw_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_public_ip.gw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_network_gateway.gw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_connection.local](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [random_string.dns](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active_active"></a> [active\_active](#input\_active\_active) | If true, an active-active Virtual Network Gateway will be created. An active-active gateway requires a HighPerformance or an UltraPerformance sku. If false, an active-standby gateway will be created. Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_bgp"></a> [enable\_bgp](#input\_enable\_bgp) | If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway. Defaults to false. | `bool` | `false` | no |
| <a name="input_generation"></a> [generation](#input\_generation) | The Generation of the Virtual Network gateway | `string` | `null` | no |
| <a name="input_local_networks"></a> [local\_networks](#input\_local\_networks) | List of local virtual network connections to connect to gateway. | `list(object({ name = string, gateway_address = string, address_space = list(string), shared_key = string, ipsec_policy = any }))` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region in which to create resource. | `any` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent. | `any` | `null` | no |
| <a name="input_log_storage_account_id"></a> [log\_storage\_account\_id](#input\_log\_storage\_account\_id) | Specifies the ID of a Storage Account where Logs should be sent. | `any` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of virtual gateway. | `any` | n/a | yes |
| <a name="input_pip_allocation_method"></a> [pip\_allocation\_method](#input\_pip\_allocation\_method) | Defines the allocation method for this IP address. Possible values are Static or Dynamic. | `string` | `"Dynamic"` | no |
| <a name="input_pip_id"></a> [pip\_id](#input\_pip\_id) | External public ip | `string` | `null` | no |
| <a name="input_pip_sku"></a> [pip\_sku](#input\_pip\_sku) | The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. | `string` | `"Basic"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group to deploy resources in. | `any` | n/a | yes |
| <a name="input_sec_log_analytics_workspace_id"></a> [sec\_log\_analytics\_workspace\_id](#input\_sec\_log\_analytics\_workspace\_id) | Log analytics workspace security (it should be in a different subscription). | `string` | `null` | no |
| <a name="input_sec_storage_id"></a> [sec\_storage\_id](#input\_sec\_storage\_id) | Storage Account security (it should be in a different subscription). | `string` | `null` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Configuration of the size and capacity of the virtual network gateway. | `any` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Id of subnet where gateway should be deployed, have to be names GatewaySubnet. | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources created. | `map(string)` | `{}` | no |
| <a name="input_vpn_client_configuration"></a> [vpn\_client\_configuration](#input\_vpn\_client\_configuration) | If set it will activate point-to-site configuration. | <pre>list(object(<br>    {<br>      aad_audience          = string<br>      aad_issuer            = string<br>      aad_tenant            = string<br>      address_space         = list(string)<br>      radius_server_address = string<br>      radius_server_secret  = string<br>      revoked_certificate = list(object(<br>        {<br>          name       = string<br>          thumbprint = string<br>        }<br>      ))<br>      root_certificate = list(object(<br>        {<br>          name             = string<br>          public_cert_data = string<br>        }<br>      ))<br>      vpn_client_protocols = list(string)<br>    }<br>  ))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The fqdn for gateway. |
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | The ID of the virtual network gateway. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_backend_address_pool_address.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) | resource |
| [azurerm_lb_probe.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocation_method"></a> [allocation\_method](#input\_allocation\_method) | (Required) Defines how an IP address is assigned. Options are Static or Dynamic. | `string` | `"Static"` | no |
| <a name="input_frontend_name"></a> [frontend\_name](#input\_frontend\_name) | (Required) Specifies the name of the frontend ip configuration. | `string` | `"LoadBalancerFrontEnd"` | no |
| <a name="input_frontend_private_ip_address"></a> [frontend\_private\_ip\_address](#input\_frontend\_private\_ip\_address) | (Optional) Private ip address to assign to frontend. Use it with type = private | `string` | `""` | no |
| <a name="input_frontend_private_ip_address_allocation"></a> [frontend\_private\_ip\_address\_allocation](#input\_frontend\_private\_ip\_address\_allocation) | (Optional) Frontend ip allocation type (Static or Dynamic) | `string` | `"Dynamic"` | no |
| <a name="input_frontend_subnet_id"></a> [frontend\_subnet\_id](#input\_frontend\_subnet\_id) | (Optional) Frontend subnet id to use when in private mode | `string` | `""` | no |
| <a name="input_lb_backend_pools"></a> [lb\_backend\_pools](#input\_lb\_backend\_pools) | (Optional) Backend pool and ip address configuration | <pre>list(object(<br/>    {<br/>      name = string<br/>      ips = list(object(<br/>        {<br/>          ip      = string<br/>          type    = optional(string)<br/>          vnet_id = string<br/>      }))<br/>  }))</pre> | <pre>[<br/>  {<br/>    "ips": [],<br/>    "name": "default"<br/>  }<br/>]</pre> | no |
| <a name="input_lb_port"></a> [lb\_port](#input\_lb\_port) | Protocols to be used for lb rules. Format as name => {frontend\_port, protocol, backend\_port, backend\_pool\_name, probe\_name} | <pre>map(object({<br/>    frontend_port     = string<br/>    protocol          = string<br/>    backend_port      = string<br/>    backend_pool_name = string<br/>    probe_name        = string<br/>  }))</pre> | `{}` | no |
| <a name="input_lb_probe"></a> [lb\_probe](#input\_lb\_probe) | (Optional) Protocols to be used for lb health probes. Format as name => {protocol, port, request\_path} | <pre>map(object({<br/>    protocol     = string<br/>    port         = string<br/>    request_path = string<br/>  }))</pre> | `{}` | no |
| <a name="input_lb_probe_interval"></a> [lb\_probe\_interval](#input\_lb\_probe\_interval) | Interval in seconds the load balancer health probe rule does a check | `number` | `5` | no |
| <a name="input_lb_probe_unhealthy_threshold"></a> [lb\_probe\_unhealthy\_threshold](#input\_lb\_probe\_unhealthy\_threshold) | Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy. | `number` | `2` | no |
| <a name="input_lb_sku"></a> [lb\_sku](#input\_lb\_sku) | (Optional) The SKU of the Azure Load Balancer. Accepted values are Basic and Standard. | `string` | `"Basic"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the load balancer. | `string` | n/a | yes |
| <a name="input_pip_sku"></a> [pip\_sku](#input\_pip\_sku) | (Optional) The SKU of the Azure Public IP. Accepted values are Basic and Standard. | `string` | `"Basic"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group where the load balancer resources will be imported. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | <pre>{<br/>  "source": "terraform"<br/>}</pre> | no |
| <a name="input_type"></a> [type](#input\_type) | (Optional) Defined if the loadbalancer is private or public | `string` | `"public"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_lb_backend_address_pool_id"></a> [azurerm\_lb\_backend\_address\_pool\_id](#output\_azurerm\_lb\_backend\_address\_pool\_id) | the id for the azurerm\_lb\_backend\_address\_pool resource |
| <a name="output_azurerm_lb_frontend_ip_configuration"></a> [azurerm\_lb\_frontend\_ip\_configuration](#output\_azurerm\_lb\_frontend\_ip\_configuration) | the frontend\_ip\_configuration for the azurerm\_lb resource |
| <a name="output_azurerm_lb_id"></a> [azurerm\_lb\_id](#output\_azurerm\_lb\_id) | the id for the azurerm\_lb resource |
| <a name="output_azurerm_private_ip_address"></a> [azurerm\_private\_ip\_address](#output\_azurerm\_private\_ip\_address) | Private IP Address to assign to the Load Balancer. |
| <a name="output_azurerm_public_ip_address"></a> [azurerm\_public\_ip\_address](#output\_azurerm\_public\_ip\_address) | the ip address for the azurerm\_lb\_public\_ip resource |
| <a name="output_azurerm_public_ip_id"></a> [azurerm\_public\_ip\_id](#output\_azurerm\_public\_ip\_id) | the id for the azurerm\_lb\_public\_ip resource |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

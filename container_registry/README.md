# azure container registry

Module that allows the creation of azure container registry.

## Architecture

TBD

## Limits and constraints

- **Private endpoints** is avaible only for Premium sku.

## How to use it

### Private mode

```ts
resource "azurerm_resource_group" "acr_rg" {
  name     = "${local.project}-acr-rg"
  location = var.location

  tags = var.tags
}

# Private endpoint subnet
module "private_endpoints_snet" {
  source               = "git::https://github.com/pagopa/azurerm.git//subnet?ref=v2.9.0"
  name                 = "private-endpoints-snet"
  resource_group_name  = data.azurerm_virtual_network.vnet.nameresource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = var.cidr_subnet_private_endpoints

  enforce_private_link_endpoint_network_policies = true
}

# DNS private container registry

resource "azurerm_private_dns_zone" "privatelink_azurecr_io" {
  name                = "privatelink.azurecr.io"
  resource_group_name = data.azurerm_resource_group.rg_vnet.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_azurecr_io_vnet_weu" {
  name                  = data.azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_private_dns_zone.privatelink_azurecr_io.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_azurecr_io.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  registration_enabled  = false

  tags = var.tags
}

module "container_registry_private" {
  source = "git::https://github.com/pagopa/azurerm.git//container_registry?ref=ref=v2.10.0"

  name                          = replace(format("%s-privare-acr", local.project), "-", "")
  location                      = var.location
  resource_group_name           = azurerm_resource_group.acr_rg.name
  sku                           = "Premium"
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  zone_redundancy_enabled       = true
  public_network_access_enabled = false

  private_endpoint = {
    enabled              = true
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurecr_io.id]
    subnet_id            = module.private_endpoints_snet.id
    virtual_network_id   = data.azurerm_virtual_network.vnet.id
  }

  georeplications = [{
    location                  = var.location_seconsary
    regional_endpoint_enabled = false
    zone_redundancy_enabled   = true
  }]

  # Logs
  sec_log_analytics_workspace_id = var.env_short == "p" ? data.azurerm_key_vault_secret.sec_workspace_id[0].value : null
  sec_storage_id                 = var.env_short == "p" ? data.azurerm_key_vault_secret.sec_storage_id[0].value : null

  tags = var.tags
}
```

### Public mode

```ts
resource "azurerm_resource_group" "acr_rg" {
  name     = "${local.project}-acr-rg"
  location = var.location

  tags = var.tags
}

module "container_registry_public" {
  source = "git::https://github.com/pagopa/azurerm.git//container_registry?ref=ref=v2.10.0"

  name                          = replace(format("%s-public-acr", local.project), "-", "")
  location                      = var.location
  resource_group_name           = azurerm_resource_group.acr_rg.name
  sku                           = "Basic"
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  zone_redundancy_enabled       = true
  public_network_access_enabled = true

  private_endpoint = {
    enabled              = false
    private_dns_zone_ids = ""
    subnet_id            = ""
    virtual_network_id   = ""
  }

  georeplications = [{
    location                  = var.location_seconsary
    regional_endpoint_enabled = false
    zone_redundancy_enabled   = true
  }]

  default = [{
    default_action  = "Allow"
    ip_rule         = []
    virtual_network = []
  }]

  tags = var.tags
}
```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | (Optional) Specifies whether the admin user is enabled. Defaults to false. | `bool` | `false` | no |
| <a name="input_anonymous_pull_enabled"></a> [anonymous\_pull\_enabled](#input\_anonymous\_pull\_enabled) | (Optional) Whether allows anonymous (unauthenticated) pull access to this Container Registry? Defaults to false. This is only supported on resources with the Standard or Premium SKU. | `bool` | `false` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | A list of Azure locations where the container registry should be geo-replicated. | <pre>list(object({<br>    location                  = string<br>    regional_endpoint_enabled = bool<br>    zone_redundancy_enabled   = bool<br>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_network_rule_bypass_option"></a> [network\_rule\_bypass\_option](#input\_network\_rule\_bypass\_option) | (Optional) Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are None and AzureServices. Defaults to AzureServices. | `string` | `"AzureServices"` | no |
| <a name="input_network_rule_set"></a> [network\_rule\_set](#input\_network\_rule\_set) | A list of network rule set defined at https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry#network_rule_set | <pre>list(object({<br>    default_action = string<br>    ip_rule = list(object({<br>      action   = string<br>      ip_range = string<br>    }))<br>    virtual_network = list(object({<br>      action    = string<br>      subnet_id = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "default_action": "Deny",<br>    "ip_rule": [],<br>    "virtual_network": []<br>  }<br>]</pre> | no |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | (Required) Enable private endpoint with required params | <pre>object({<br>    enabled              = bool<br>    virtual_network_id   = string<br>    subnet_id            = string<br>    private_dns_zone_ids = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for the container registry. Defaults to true. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_sec_log_analytics_workspace_id"></a> [sec\_log\_analytics\_workspace\_id](#input\_sec\_log\_analytics\_workspace\_id) | Log analytics workspace security (it should be in a different subscription). | `string` | `null` | no |
| <a name="input_sec_storage_id"></a> [sec\_storage\_id](#input\_sec\_storage\_id) | Storage Account security (it should be in a different subscription). | `string` | `null` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | (Required) The SKU name of the container registry. Possible values are Basic, Standard and Premium. | `string` | `"Basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled) | (Optional) Whether zone redundancy is enabled for this Container Registry? Changing this forces a new resource to be created. Defaults to false. | `string` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | n/a |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

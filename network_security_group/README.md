# Azure Network Security Group Module

This module manages Network Security Groups (NSGs) in Azure, allowing fine-grained control over network traffic to subnets. It supports custom inbound/outbound rules and network traffic analysis through Network Watcher.

## Features

- Creates NSGs and associates them with target subnets
- Configures inbound and outbound security rules
- Supports predefined services (PostgreSQL, Redis, Cosmos DB, Event Hub, Storage)
- Enables Network Watcher with traffic analytics
- Validates rule configurations for correctness

## Usage

### Basic Configuration

```hcl
module "network_security_group" {
  source = "./network_security_group"

  prefix              = "dev"
  resource_group_name = "my-rg"
  location           = "westeurope"

  vnets = [
    {
      name    = "vnet1"
      rg_name = "vnet-rg"
    }
  ]

  custom_security_group = {
    myNsg = {
      target_subnet_name      = "subnet1" # where the NSG will be associated
      target_subnet_vnet_name = "vnet1" # where the NSG will be associated
      watcher_enabled         = true

      inbound_rules  = [
        {
          name                       = "AllowHTTP"
          priority                   = 200
          protocol                   = "Tcp"
          source_subnet_name         = module.private_endpoints_snet.name
          source_subnet_vnet_name    = module.vnet.name
          destination_port_ranges    = ["80"]
          description                = "Allow HTTP traffic on 80" 
        }
      ]
      outbound_rules = [
        {
          name                       = "AllowMySQL"
          priority                   = 200
          protocol                   = "Tcp"
          destination_port_ranges    = ["3306"]
          destination_subnet_name    = azurerm_subnet.tools_cae_snet.name
          destination_subnet_vnet_name = module.vnet_italy.name
          description                = "Allow MySQL traffic on 3306"
        }
      ]
    }
  }

  network_watcher = {
    storage_account_id         = "storage-id"
    retention_days            = 30
    traffic_analytics_law_name = "law-name"
    traffic_analytics_law_rg   = "law-rg"
  }
}
```

## Input variables

### Required Variables

| Name                | Type         | Description                                                                        |
| ------------------- | ------------ |------------------------------------------------------------------------------------|
| prefix              | string       | Resource prefix (max 6 chars)                                                      |
| resource_group_name | string       | Resource group name where the NSG will be created                                  |
| location            | string       | Azure region                                                                       |
| vnets               | list(object) | VNet configurations, referenced in the rules. Used to retrieve the subnets details |
| network_watcher     | object       | Network Watcher settings                                                           |
| tags                | map(string)  | Resource tags                                                                      |

### Custom Security Group Configuration

The custom_security_group variable accepts a map of security group configurations:

| Field                   | Type         | Description                                                                                                                                                                                      | Default  |
| ----------------------- | ------------ |--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| -------- |
| target_subnet_name      | string       | Subnet to which the NSG will be associated. Its CIDR will be used as default  `destination_address_prefixes` and `source_address_prefixes` for `inbound_rules` and `outbound_rules` respectively | Required |
| target_subnet_vnet_name | string       | Vnet name to which the `target_subnet_name` belongs                                                                                                                                              | Required |
| watcher_enabled         | bool         | Enable Network Watcher on this NSG                                                                                                                                                               | false    |
| inbound_rules           | list(object) | Inbound rule configurations                                                                                                                                                                      | Required |
| outbound_rules          | list(object) | Outbound rule configurations                                                                                                                                                                     | Required |

### Rule Configuration

**Inbound rule supports:**

| Field                        | Type         | Description                                                                | Default                         | Valid values                                       |
|------------------------------| ------------ |----------------------------------------------------------------------------|---------------------------------|----------------------------------------------------|
| name                         | string       | Rule name                                                                  | Required                        | -                                                  |
| priority                     | number       | Rule priority                                                              | Required                        | between 100 and 4096                               |
| target_service               | string       | Target service name                                                        | null                            | postgresql, redis, cosmos, eventhub, storage       |
| access                       | string       | Action applied by this rule                                                | "Allow"                         | `Allow`, `Deny`                                    |
| protocol                     | string       | Network protocol                                                           | Required if target_service null | `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah`, `*`             |
| source_subnet_name           | string | Source subnet name. Mutually exclusive with `source_address_prefixes`      | null                            | Subnet name where the traffic is originated        |
| source_subnet_vnet_name      | string | Source subnet vnet name. Mutually exclusive with `source_address_prefixes` | null                            | Vnet name where the traffic is originated          |
| source_address_prefixes      | list(string) | Source addresses, defaults to `source_subnet_name` CIDR                    | []                              | IPs, CIDRs, `*`, service tag                       |
| source_port_ranges           | list(string) | Source ports                                                               | ["*"]                           | Port numbers, ranges (`80`, `1024-2048`), wildcard |
| destination_port_ranges      | list(string) | Destination ports                                                          | ["*"]                           | Port numbers, ranges (`80`, `1024-2048`), wildcard |
| destination_address_prefixes | list(string) | Destination addresses, defaults to `target_subnet_name` CIDR                                                    | []                              | IPs, CIDRs, `*`, service tag                       |
| description                  | string | Description for this rule                                                  | null                            | any string, max 140 chars                          |


**Outbound rules support:**

| Field                        | Type         | Description                                                                          | Default                         | Valid values                                       |
|------------------------------| ------------ |--------------------------------------------------------------------------------------|---------------------------------|----------------------------------------------------|
| name                         | string       | Rule name                                                                            | Required                        | -                                                  |
| priority                     | number       | Rule priority                                                                        | Required                        | between 100 and 4096                               |
| target_service               | string       | Target service name                                                                  | null                            | postgresql, redis, cosmos, eventhub, storage       |
| access                       | string       | Action applied by this rule                                                          | "Allow"                         | `Allow`, `Deny`                                    |
| protocol                     | string       | Network protocol                                                                     | Required if target_service null | `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah`, `*`             |
| source_address_prefixes      | list(string) | Source addresses, defaults to `target_subnet_name` CIDR                              | []                              | IPs, CIDRs, `*`, service tag                       |
| source_port_ranges           | list(string) | Source ports                                                                         | ["*"]                           | Port numbers, ranges (`80`, `1024-2048`), wildcard |
| destination_subnet_name      | string | Destination subnet name. Mutually exclusive with `destination_address_prefixes`      | null                            | Subnet name where the traffic is destinated        |
| destination_subnet_vnet_name | string | Destination subnet vnet name. Mutually exclusive with `destination_address_prefixes` | null                            | Vnet name where the traffic is destinated          |
| destination_port_ranges      | list(string) | Destination ports                                                                    | ["*"]                           | Port numbers, ranges (`80`, `1024-2048`), wildcard |
| destination_address_prefixes | list(string) | Destination addresses,  defaults to `destination_subnet_name` CIDR                        | []                              | IPs, CIDRs, `*`, service tag                       |
| description                  | string | Description for this rule                                                            | null                            | any string, max 140 chars                          |
 

Some examples of inbound rule configurations, these examples are valid also for outbound rules after swapping `source_subnet_name` and `source_subnet_vnet_name` with `destination_subnet_name` and `destination_subnet_vnet_name` respectively.

- Allowing default http port on target_subnet_name from source_subnet_name
```hcl
{
  name                       = "AllowHTTP"
  priority                   = 200
  protocol                   = "Tcp"
  source_subnet_name         = module.private_endpoints_snet.name
  source_subnet_vnet_name    = module.vnet.name
  destination_port_ranges    = ["80"]
  description                = "Allow HTTP traffic on 80" 
}
```

- Allowing default http port on target_subnet_name from a specific CIDR
```hcl
{
  name                       = "AllowHTTP"
  priority                   = 200
  protocol                   = "Tcp"
  source_address_prefixes    = ["10.1.2.0/24"]
  destination_port_ranges    = ["80"]
  description                = "Allow HTTP traffic on 80" 
}
```

- Allowing default http port on a specific address from a specific CIDR
```hcl
{
  name                         = "AllowHTTP"
  priority                     = 200
  protocol                     = "Tcp"
  source_address_prefixes      = ["10.1.2.0/24"]
  destination_address_prefixes = ["10.1.3.100"]
  destination_port_ranges      = ["80"]
  description                  = "Allow HTTP traffic on 80" 
}
```


- Denying default http port on target_subnet_name from a specific CIDR
```hcl
{
  name                       = "DenyHTTP"
  priority                   = 200
  access                     = "Deny"
  protocol                   = "Tcp"
  source_address_prefixes    = ["10.1.2.0/24"]
  destination_port_ranges    = ["80"]
  description                = "Deny HTTP traffic on 80" 
}
```

- Allowing postgresql port and protocol from a specific subnet
```hcl
{
  name                       = "AllowPostgresql"
  priority                   = 200
  target_service             = "postgresql"
  source_subnet_name         = module.private_endpoints_snet.name
  source_subnet_vnet_name    = module.vnet.name
  description                = "Allow postgresql ports and protocol" 
}
```

### Network Watcher Configuration

| Field                                  | Type   | Description                            | Default  |
| -------------------------------------- | ------ | -------------------------------------- | -------- |
| storage_account_id                     | string | Storage account ID                     | Required |
| retention_days                         | number | Log retention period                   | Required |
| traffic_analytics_law_name             | string | Log Analytics workspace name           | Required |
| traffic_analytics_law_rg               | string | Log Analytics workspace resource group | Required |
| traffic_analytics_law_interval_minutes | number | Analysis interval                      | 10       |



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
| [azurerm_network_watcher.network_watcher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_network_watcher_flow_log.network_watcher_flow_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_subnet_network_security_group_association.nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_log_analytics_workspace.analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_security_group"></a> [custom\_security\_group](#input\_custom\_security\_group) | security groups configuration | <pre>map(object({<br/>    target_subnet_name      = string<br/>    target_subnet_vnet_name = string<br/>    watcher_enabled         = optional(bool, false)<br/>    inbound_rules = list(object({<br/>      name                         = string<br/>      priority                     = number<br/>      target_service               = optional(string, null)<br/>      access                       = optional(string, "Allow")<br/>      protocol                     = optional(string)<br/>      source_subnet_name           = optional(string)<br/>      source_subnet_vnet_name      = optional(string)<br/>      source_port_ranges           = optional(list(string), ["*"])<br/>      source_address_prefixes      = optional(list(string), [])<br/>      destination_address_prefixes = optional(list(string), [])<br/>      destination_port_ranges      = optional(list(string), ["*"])<br/>      description                  = optional(string)<br/>    }))<br/><br/>    outbound_rules = list(object({<br/>      name                         = string<br/>      priority                     = number<br/>      target_service               = optional(string, null)<br/>      access                       = optional(string, "Allow")<br/>      protocol                     = optional(string)<br/>      source_address_prefixes      = optional(list(string), [])<br/>      source_port_ranges           = optional(list(string), ["*"])<br/>      destination_subnet_name      = optional(string)<br/>      destination_subnet_vnet_name = optional(string)<br/>      destination_port_ranges      = optional(list(string), ["*"])<br/>      destination_address_prefixes = optional(list(string), [])<br/>      description                  = optional(string)<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the resource group where the nsg will be saved | `string` | n/a | yes |
| <a name="input_network_watcher"></a> [network\_watcher](#input\_network\_watcher) | Parameters required to configure the network watcher | <pre>object({<br/>    storage_account_id                     = string<br/>    retention_days                         = number<br/>    traffic_analytics_law_name             = string<br/>    traffic_analytics_law_rg               = string<br/>    traffic_analytics_law_interval_minutes = optional(number, 10)<br/>  })</pre> | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resources | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the nsg will be saved | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to the nsg | `map(string)` | n/a | yes |
| <a name="input_vnets"></a> [vnets](#input\_vnets) | n/a | <pre>list(object({<br/>    name    = string<br/>    rg_name = string<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

# Migration guide for generic resources

## azurerm_public_ip

🔥 Manual state changes

* you need to removed this field form state.
* and change `zones` and leave an empty array if the ip is no zone redundant, or put `[1,2,3]` for zone redundant

```json
    {
      "module": "module.vpn",
      "mode": "managed",
      "type": "azurerm_public_ip",
      "name": "gw",
      "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
      "instances": [
        {
          "index_key": 0,
          "schema_version": 0,
          "attributes": {
            "allocation_method": "Dynamic",
            "availability_zone": "No-Zone", <--- Remove this one <<
            "domain_name_label": "dvopladvpngwmgmciz",
            "fqdn": "xxx",
            "id": "xxx",
            "idle_timeout_in_minutes": 4,
            "ip_address": "20.107.195.23",
            "ip_tags": {},
            "ip_version": "IPv4",
            "location": "northeurope",
            "name": "dvopla-d-vpn-gw-pip",
            "public_ip_prefix_id": null,
            "resource_group_name": "dvopla-d-vnet-rg",
            "reverse_fqdn": "",
            "sku": "Basic",
            "sku_tier": "Regional",
            "tags": {
              "CostCenter": "TS310 - PAGAMENTI \u0026 SERVIZI",
              "CreatedBy": "Terraform",
              "Environment": "Lab",
              "Owner": "DevOps",
              "Source": "https://github.com/pagopa/devopslab-infra"
            },
            "timeouts": null,
            "zones": []
          },
          "sensitive_attributes": [],
          "private": xxx,
          "dependencies": [
            "azurerm_resource_group.rg_vnet",
            "module.vpn.random_string.dns"
          ]
        }
      ]
    },
```


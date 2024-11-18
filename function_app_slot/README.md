# Azure function app slot

Module that allows the creation of an Azure function app slot.
It creates a resource group named `azrmtest<6 hexnumbers>-rg` and every resource into it is named `azrmtest<6 hexnumbers>-*`.
In terraform output you can get the resource group name.

## How to use it

Use the example Terraform template, saved in `terraform-azurerm-v3/function_app_slot/tests`, to test this module.
It creates a resource group named `test-fnappslot<6 hexnumbers>-rg` and every resource into it is named `fnappslot<6 hexnumbers>-*`

## How to migrate from ```azurerm_function_app_slot``` to ```azurerm_linux_function_app_slot```

The following script will remove and import the deprecated resources as new ones.
It creates a resource group named `test-fnappslot<6 hexnumbers>-rg` and every resource into it is named `fnappslot<6 hexnumbers>-*`

# Check if the "Terraform" and "jq" commands are available
if ! which terraform &> /dev/null && which jq &> /dev/null; then
  echo "Please install terraform and jq before proceeding."
  exit 1
fi
removeAndImport "module.function_app_slot.azurerm_function_app_slot.this" "module.function_app_slot.azurerm_linux_function_app_slot.this"
```

## Migration from v2

Output for resource `azurerm_function_app_host_keys` changed

See [Generic resorce migration](../docs/MIGRATION_GUIDE_GENERIC_RESOURCES.md)

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->

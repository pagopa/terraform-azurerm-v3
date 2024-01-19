# Dns Forwarder

This module allows the creation of infrastructure for a custom DNS forwarder. The infrastructure consists of a Load Balancer with a static IP that directs traffic towards a Virtual Machine Scale Set. Additionally, two subnets are created dedicated to the Load Balancer and the VMSS with the following default values:

- Load_balancer: 10.1.200.0/29
- VM_scale_set: 10.1.200.9/29

To secure the scale set, a Network Security Group has been added, allowing inbound traffic only on port 53 (TCP/UDP) from the specified Virtual Network.

## How to use

```hcl

module "dns_forwarder" {

  source              = "git::https://github.com/pagopa/terraform-azurerm-v3.git//dns_forwarder_lb_vmss?ref=7.48.0"

  name                 = var.prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  subscription_id      = data.azurerm_subscription.current.subscription_id
  source_image_name    = var.source_image_name
  tenant_id            = data.azurerm_client_config.current.tenant_id

  tags = var.tags
}

```
<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.85.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | <= 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | git::https://github.com/pagopa/terraform-azurerm-v3.git//key_vault | v7.47.0 |
| <a name="module_lb"></a> [lb](#module\_lb) | git::https://github.com/pagopa/terraform-azurerm-v3.git//load_balancer | v7.47.0 |
| <a name="module_subnet_lb"></a> [subnet\_lb](#module\_subnet\_lb) | git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet | v7.47.0 |
| <a name="module_subnet_vmss"></a> [subnet\_vmss](#module\_subnet\_vmss) | git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet | v7.47.0 |
| <a name="module_vmss"></a> [vmss](#module\_vmss) | git::https://github.com/pagopa/terraform-azurerm-v3.git//vm_scale_set | v7.47.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.psw_vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_network_security_group.vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [random_password.psw](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefixes_lb"></a> [address\_prefixes\_lb](#input\_address\_prefixes\_lb) | (Optional) The address prefixes to use for load balancer subnet. | `string` | `"10.1.200.0/29"` | no |
| <a name="input_address_prefixes_vmss"></a> [address\_prefixes\_vmss](#input\_address\_prefixes\_vmss) | (Optional) The address prefixes to use for the virtual machine scale set subnet. | `string` | `"10.1.200.9/29"` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created. will be stored in the raw state as plain-text | `string` | `null` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | (Required) Type of authentication to use with the VM. Defaults to password for Windows and SSH public key for Linux. all enables both ssh and password authentication. | `string` | `"SSH"` | no |
| <a name="input_capacity_default_count"></a> [capacity\_default\_count](#input\_capacity\_default\_count) | (Optional) The number of instances that are available for scaling if metrics are not available for evaluation. The default is only used if the current instance count is lower than the default. Valid values are between 0 and 1000 | `number` | `1` | no |
| <a name="input_capacity_maximum_count"></a> [capacity\_maximum\_count](#input\_capacity\_maximum\_count) | (Optional) The maximum number of instances for this resource. Valid values are between 0 and 1000 | `number` | `1` | no |
| <a name="input_capacity_minimum_count"></a> [capacity\_minimum\_count](#input\_capacity\_minimum\_count) | (Optional) The minimum number of instances for this resource. Valid values are between 0 and 1000 | `number` | `1` | no |
| <a name="input_encryption_set_id"></a> [encryption\_set\_id](#input\_encryption\_set\_id) | (Optional) An existing encryption set | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the Virtual Machine Scale Set, Load Balancer. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group in which the resources should be exist. | `string` | n/a | yes |
| <a name="input_source_image_name"></a> [source\_image\_name](#input\_source\_image\_name) | (Required) The name of an Image which each Virtual Machine in this Scale Set should be based on. It must be stored in the same subscription & resource group of this resource | `string` | n/a | yes |
| <a name="input_static_address_lb"></a> [static\_address\_lb](#input\_static\_address\_lb) | (Optional) The static address of load balancer. | `string` | `null` | no |
| <a name="input_storage_sku"></a> [storage\_sku](#input\_storage\_sku) | (Optional) The SKU of the storage account with which to persist VM. Use a singular sku that would be applied across all disks, or specify individual disks. Usage: [--storage-sku SKU \| --storage-sku ID=SKU ID=SKU ID=SKU...], where each ID is os or a 0-indexed lun. Allowed values: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS, UltraSSD\_LRS, Premium\_ZRS, StandardSSD\_ZRS. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_subnet_lb_id"></a> [subnet\_lb\_id](#input\_subnet\_lb\_id) | (Optional) The subnet id of load balancer. | `string` | `null` | no |
| <a name="input_subnet_vmss_id"></a> [subnet\_vmss\_id](#input\_subnet\_vmss\_id) | (Optional) The subnet id of virtual machine scale set. | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) Azure subscription id | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Required) Tags of all resources. | `map(any)` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | (Required) The Azure AD tenant ID that should be used for authenticating requests to the key vault. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Required) The name of the virtual network in which the resources (Vmss, LB) are located. | `string` | n/a | yes |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | (Optional) Size of VMs in the scale set. Default to Standard\_B1s. See https://azure.microsoft.com/pricing/details/virtual-machines/ for size info. | `string` | `"Standard_B1s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | n/a |
| <a name="output_subnet_lb_id"></a> [subnet\_lb\_id](#output\_subnet\_lb\_id) | n/a |
| <a name="output_subnet_vmss_id"></a> [subnet\_vmss\_id](#output\_subnet\_vmss\_id) | n/a |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

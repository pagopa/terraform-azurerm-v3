# Kubernetes Workload Identity init

Module that allows the creation of a workload identity.

To enable workload identity this others resources are created:

* User managed identity
* lock (this allow to avoid to delete the managed identity and change the client used by apps)

## How to use it

```hcl
module "workload_identity" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_workload_identity_init?ref=<your version>"

  workload_name_prefix = var.domain
  workload_identity_resource_group_name = data.azurerm_kubernetes_cluster.aks.resource_group_name
  workload_identity_location = var.location
}
```

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.110 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.managed_identity_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_lock"></a> [enable\_lock](#input\_enable\_lock) | Allow to enable of disable lock for managed identity | `bool` | `true` | no |
| <a name="input_workload_identity_location"></a> [workload\_identity\_location](#input\_workload\_identity\_location) | (Required) The Azure Region where the User Assigned Identity should exist. Changing this forces a new User Assigned Identity to be created. | `string` | n/a | yes |
| <a name="input_workload_identity_name"></a> [workload\_identity\_name](#input\_workload\_identity\_name) | (Optional) The full name for the user assigned identity and Workload identity. Changing this forces a new identity to be created. | `string` | `null` | no |
| <a name="input_workload_identity_name_prefix"></a> [workload\_identity\_name\_prefix](#input\_workload\_identity\_name\_prefix) | (Required) The name prefix of the user assigned identity and Workload identity. Changing this forces a new identity to be created. | `string` | n/a | yes |
| <a name="input_workload_identity_resource_group_name"></a> [workload\_identity\_resource\_group\_name](#input\_workload\_identity\_resource\_group\_name) | (Required) Specifies the name of the Resource Group within which this User Assigned Identity should exist. Changing this forces a new User Assigned Identity to be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_assigned_identity_client_id"></a> [user\_assigned\_identity\_client\_id](#output\_user\_assigned\_identity\_client\_id) | n/a |
| <a name="output_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#output\_user\_assigned\_identity\_id) | n/a |
| <a name="output_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#output\_user\_assigned\_identity\_name) | n/a |
| <a name="output_user_assigned_identity_principal_id"></a> [user\_assigned\_identity\_principal\_id](#output\_user\_assigned\_identity\_principal\_id) | n/a |
| <a name="output_user_assigned_identity_resource_group_name"></a> [user\_assigned\_identity\_resource\_group\_name](#output\_user\_assigned\_identity\_resource\_group\_name) | n/a |
| <a name="output_workload_identity_client_id"></a> [workload\_identity\_client\_id](#output\_workload\_identity\_client\_id) | n/a |
| <a name="output_workload_identity_principal_id"></a> [workload\_identity\_principal\_id](#output\_workload\_identity\_principal\_id) | n/a |
<!-- END_TF_DOCS -->

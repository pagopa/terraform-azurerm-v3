<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
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
| [azurerm_data_factory.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory) | resource |
| [azurerm_data_factory_managed_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_managed_private_endpoint) | resource |
| [azurerm_private_dns_a_record.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_domain_enabled"></a> [custom\_domain\_enabled](#input\_custom\_domain\_enabled) | If not null enables custom domain for the private endpoint | `string` | n/a | yes |
| <a name="input_github_conf"></a> [github\_conf](#input\_github\_conf) | Configuration of the github repo associated to the data factory | <pre>object({<br/>    account_name    = string<br/>    branch_name     = string<br/>    git_url         = string<br/>    repository_name = string<br/>    root_folder     = string<br/>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure Location in which the resources are located | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Short Resource Name, used to customize subresource names | `string` | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Enable private endpoint with required params | <pre>object({<br/>    enabled   = bool<br/>    subnet_id = string<br/>    private_dns_zone = object({<br/>      id   = string<br/>      name = string<br/>      rg   = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group in which the resources are located | `string` | n/a | yes |
| <a name="input_resources_managed_private_enpoint"></a> [resources\_managed\_private\_enpoint](#input\_resources\_managed\_private\_enpoint) | Map of resource to which a data factory must connect via managed private endpoint | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

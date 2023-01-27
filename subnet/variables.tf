variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "address_prefixes" {
  type        = list(string)
  description = "(Optional) The address prefixes to use for the subnet. (e.g. ['10.1.137.0/24'])"
  default     = []
}

variable "delegation" {
  type = object({
    name = string #(Required) A name for this delegation.
    service_delegation = object({
      name    = string       #(Required) The name of service to delegate to. Possible values are https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet#service_delegation
      actions = list(string) #(Optional) A list of Actions which should be delegated. Here the list: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet#actions
    })
  })

  default = null
}

variable "service_endpoints" {
  type        = list(string)
  default     = []
  description = "(Optional) The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web."
}

variable "private_endpoint_network_policies_enabled" {
  type        = bool
  description = "(Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true."
  default     = false
}

variable "private_link_service_network_policies_enabled" {
  type        = bool
  description = "(Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true."
  default     = true
}

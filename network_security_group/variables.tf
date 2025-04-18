variable "prefix" {
  type = string
  description = "Prefix for all resources"
  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "Max length is 6 chars."
  }
}


variable "resource_group_name" {
  description = "Name of the resource group where the nsg will be saved"
  type        = string
}

variable "location" {
  description = "Location of the resource group where the nsg will be saved"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the nsg"
  type        = map(string)
}

variable "custom_security_group" {
  description = "security groups configuration"
  type = map(object({
    target_subnet_name                    = string
    target_subnet_vnet_name               = string
    target_application_security_group_ids = optional(list(string))
    inbound_rules   = list(object({
      name                                       = string
      priority                                   = number
      access                                     = string
      protocol                                   = string
      source_subnet_name                         = string
      source_subnet_vnet_name                    = string
      source_application_security_group_ids      = optional(list(string))
      source_port_range                          = optional(string, "*")
      source_port_ranges                         = optional(list(string))
      source_address_prefix                      = optional(string)
      source_address_prefixes                   = optional(list(string))
      destination_address_prefixes               = optional(list(string))
      destination_port_range                     = optional(string, "*")
      destination_port_ranges                    = optional(list(string))
      description                                = optional(string) // todo validation 140 caratteri
    }))

    outbound_rules   = list(object({
      name                                       = string
      priority                                   = number
      access                                     = string
      protocol                                   = string
      source_address_prefixes                    = optional(list(string))
      source_port_range                          = optional(string, "*")
      source_port_ranges                         = optional(list(string))
      destination_subnet_name                    = string
      destination_subnet_vnet_name               = string
      destination_application_security_group_ids = optional(list(string))
      destination_port_range                     = optional(string, "*")
      destination_port_ranges                    = optional(list(string))
      destination_address_prefix                 = optional(string)
      destination_address_prefixes                 = optional(list(string))
      description                                = optional(string) // todo validation 140 caratteri
    }))
  }))
  default = null
}





variable "default_security_group" {
  description = ""
  type = map(object({
    type = string //todo validate on available types

    source_subnet_name = string
    source_subnet_vnet_name = string

    destination_subnet_name = string
    destination_subnet_vnet_name = string
  }))
  default = null
}


variable "vnets" {
  description = ""
  type = list(object({
    name = string
    rg_name   = string
  }))
}

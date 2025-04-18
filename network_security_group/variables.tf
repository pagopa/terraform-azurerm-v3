variable "prefix" {
  type        = string
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
    inbound_rules = list(object({
      name                                  = string
      priority                              = number
      access                                = string
      protocol                              = string
      source_subnet_name                    = string
      source_subnet_vnet_name               = string
      source_application_security_group_ids = optional(list(string))
      source_port_ranges                    = optional(list(string), ["*"])
      source_address_prefixes               = optional(list(string), [])
      destination_address_prefixes          = optional(list(string), [])
      destination_port_ranges               = optional(list(string), ["*"])
      description                           = optional(string)
    }))

    outbound_rules = list(object({
      name                                       = string
      priority                                   = number
      access                                     = string
      protocol                                   = string
      source_address_prefixes                    = optional(list(string), [])
      source_port_ranges                         = optional(list(string), ["*"])
      destination_subnet_name                    = string
      destination_subnet_vnet_name               = string
      destination_application_security_group_ids = optional(list(string))
      destination_port_ranges                    = optional(list(string), ["*"])
      destination_address_prefixes               = optional(list(string), [])
      description                                = optional(string)
    }))
  }))
  default = null

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten([
      [
        for nsg in var.custom_security_group : [
          [for rule in nsg.inbound_rules : (rule.description == null ? true : length(rule.description) <= 140)],
          [for rule in nsg.outbound_rules : (rule.description == null ? true : length(rule.description) <= 140)]
        ]
      ]
    ]))
    error_message = "La lunghezza massima consentita per il campo description è di 140 caratteri."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten(
      [
        for nsg in var.custom_security_group : [
          for rule in concat(nsg.inbound_rules, nsg.outbound_rules) : (
            length(rule.source_address_prefixes) == 0 ||                                                                         # vuoto
            (length(rule.source_address_prefixes) > 0 && length(rule.source_address_prefixes) == 1 && rule.source_address_prefixes[0] == "*") ||                             # solo "*"
            (length(rule.source_address_prefixes) > 0 && length(rule.source_address_prefixes) == 1 && length(regexall("[A-Za-z]", rule.source_address_prefixes[0])) > 0) ||  # solo un elemento "servicetag"
            alltrue([for prefix in rule.source_address_prefixes : can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(/\\d{1,2})?$", prefix))]) # lista di IP/CIDR validi
          )
        ]
    ]))
    error_message = "source_address_prefixes deve essere: vuoto, o contenere solo '*', o un singolo elemento servicetag, o una lista di IP/CIDR validi."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten(
      [
        for nsg in var.custom_security_group : [
          for rule in concat(nsg.inbound_rules, nsg.outbound_rules) : (
            length(rule.destination_address_prefixes) == 0 ||                                                                             # vuoto
            (length(rule.destination_address_prefixes) > 0 && length(rule.destination_address_prefixes) == 1 && rule.destination_address_prefixes[0] == "*") ||                            # solo "*"
            (length(rule.destination_address_prefixes) > 0 && length(rule.destination_address_prefixes) == 1 && length(regexall("[A-Za-z]", rule.destination_address_prefixes[0])) > 0) || # solo un elemento "servicetag"
            alltrue([for prefix in rule.destination_address_prefixes : can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(/\\d{1,2})?$", prefix))])     # lista di IP/CIDR validi
          )
        ]
    ]))
    error_message = "destination_address_prefixes deve essere: vuoto, o contenere solo '*', o un singolo elemento servicetag, o una lista di IP/CIDR validi."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten(
      [
        for nsg in var.custom_security_group : [
          for rule in concat(nsg.inbound_rules, nsg.outbound_rules) : (
            length(rule.source_port_ranges) == 0 ||                                             # vuoto
            (length(rule.source_port_ranges) == 1 && rule.source_port_ranges[0] == "*") ||      # solo "*"
            alltrue([for port in rule.source_port_ranges : can(regex("^\\d+(-\\d+)?$", port))]) # lista di porte/range validi
          )
        ]
    ]))
    error_message = "source_port_ranges deve essere: vuoto, o contenere solo '*', o una lista di porte (es: '80') o port range (es: '1024-2048')."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten(
      [
        for nsg in var.custom_security_group : [
          for rule in concat(nsg.inbound_rules, nsg.outbound_rules) : (
            length(rule.destination_port_ranges) == 0 ||                                             # vuoto
            (length(rule.destination_port_ranges) == 1 && rule.destination_port_ranges[0] == "*") || # solo "*"
            alltrue([for port in rule.destination_port_ranges : can(regex("^\\d+(-\\d+)?$", port))]) # lista di porte/range validi
          )
        ]
    ]))
    error_message = "destination_port_ranges deve essere: vuoto, o contenere solo '*', o una lista di porte (es: '80') o port range (es: '1024-2048')."
  }
}





variable "default_security_group" {
  description = ""
  type = map(object({
    type = string //todo validate on available types

    source_subnet_name      = string
    source_subnet_vnet_name = string

    destination_subnet_name      = string
    destination_subnet_vnet_name = string
  }))
  default = null
}


variable "vnets" {
  description = ""
  type = list(object({
    name    = string
    rg_name = string
  }))
}

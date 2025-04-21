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
    deny_everything_else_inbound          = optional(bool, false)
    deny_everything_else_outbound         = optional(bool, false)
    inbound_rules = list(object({
      name                                  = string
      priority                              = number
      access                                = optional(string, "Allow")
      protocol                              = optional(string)
      source_subnet_name                    = optional(string)
      source_subnet_vnet_name               = optional(string)
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
      access                                     = optional(string, "Allow")
      protocol                                   = optional(string)
      source_address_prefixes                    = optional(list(string), [])
      source_port_ranges                         = optional(list(string), ["*"])
      destination_subnet_name                    = optional(string)
      destination_subnet_vnet_name               = optional(string)
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
            length(rule.source_address_prefixes) == 0 ||                                                                                               # vuoto
            (length(rule.source_address_prefixes) == 1 && alltrue([for p in rule.source_address_prefixes : (p == "*")])) ||                            # solo "*"
            (length(rule.source_address_prefixes) == 1 && alltrue([for p in rule.source_address_prefixes : (length(regexall("[A-Za-z]", p)) > 0)])) || # solo un elemento "servicetag"
            alltrue([for prefix in rule.source_address_prefixes : can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(/\\d{1,2})?$", prefix))])                       # lista di IP/CIDR validi
          )
        ]
    ]))
    error_message = "source_address_prefixes must be: empty, or contain only '*', or a single servicetag element, or a list of valid IP/CIDR."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten(
      [
        for nsg in var.custom_security_group : [
          for rule in concat(nsg.inbound_rules, nsg.outbound_rules) : (
            length(rule.destination_address_prefixes) == 0 ||                                                                                                    # vuoto
            (length(rule.destination_address_prefixes) == 1 && alltrue([for p in rule.destination_address_prefixes : (p == "*")])) ||                            # solo "*"
            (length(rule.destination_address_prefixes) == 1 && alltrue([for p in rule.destination_address_prefixes : (length(regexall("[A-Za-z]", p)) > 0)])) || # solo un elemento "servicetag"
            alltrue([for prefix in rule.destination_address_prefixes : can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(/\\d{1,2})?$", prefix))])                            # lista di IP/CIDR validi
          )
        ]
    ]))
    error_message = "destination_address_prefixes must be: empty, or contain only '*', or a single servicetag element, or a list of valid IP/CIDR."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten(
      [
        for nsg in var.custom_security_group : [
          for rule in concat(nsg.inbound_rules, nsg.outbound_rules) : (
            length(rule.source_port_ranges) == 0 ||                                                               # vuoto
            (length(rule.source_port_ranges) == 1 && alltrue([for p in rule.source_port_ranges : (p == "*")])) || # solo "*"
            alltrue([for port in rule.source_port_ranges : can(regex("^\\d+(-\\d+)?$", port))])                   # lista di porte/range validi
          )
        ]
    ]))
    error_message = "source_port_ranges must be: empty, or contain only '*', or a list of ports (e.g., '80') or port ranges (e.g., '1024-2048')."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten(
      [
        for nsg in var.custom_security_group : [
          for rule in concat(nsg.inbound_rules, nsg.outbound_rules) : (
            length(rule.destination_port_ranges) == 0 ||                                                                    # vuoto
            (length(rule.destination_port_ranges) == 1 && alltrue([for p in rule.destination_port_ranges : (p == "*")])) || # solo "*"
            alltrue([for port in rule.destination_port_ranges : can(regex("^\\d+(-\\d+)?$", port))])                        # lista di porte/range validi
          )
        ]
    ]))
    error_message = "destination_port_ranges must be: empty, or contain only '*', or a list of ports (e.g., '80') or port ranges (e.g., '1024-2048')."
  }




  validation {
    condition = var.custom_security_group == null ? true : alltrue([
      for nsg in var.custom_security_group : (
        length(distinct([for rule in nsg.inbound_rules : rule.priority])) == length(nsg.inbound_rules)
      )
    ])
    error_message = "Inbound rules priority must be unique."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue([
      for nsg in var.custom_security_group : (
        length(distinct([for rule in nsg.outbound_rules : rule.priority])) == length(nsg.outbound_rules)
      )
    ])
    error_message = "Outbound rules priority must be unique."
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten([
      for nsg in var.custom_security_group : (
        [
          for rule in nsg.outbound_rules : (rule.priority < 4096)
        ]
      )
      ])
    )
    error_message = "Outbound rules priority 4096 is reserved for deny_everything_else_outbound rule"
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten([
      for nsg in var.custom_security_group : (
        [
          for rule in nsg.inbound_rules : (rule.priority < 4096)
        ]
      )
      ])
    )
    error_message = "Inbound rules priority 4096 is reserved for deny_everything_else_inbound rule"
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten([
      for nsg in var.custom_security_group : [
        for rule in concat(nsg.inbound_rules, nsg.outbound_rules) : (
          contains(["Allow", "Deny"], rule.access)
        )
      ]
    ]))
    error_message = "Access must be either 'Allow' or 'Deny'."
  }


  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten([
      for nsg in var.custom_security_group : [
        for rule in nsg.outbound_rules : (
          (rule.destination_subnet_name != null && length(rule.destination_address_prefixes) == 0) ||
        (rule.destination_subnet_name == null && length(rule.destination_address_prefixes) > 0)
        )
      ]
    ]))
    error_message = "outbound_rules: destination_subnet_name and destination_address_prefixes are mutually exclusive"
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten([
      for nsg in var.custom_security_group : [
        for rule in nsg.inbound_rules : (
        (rule.source_subnet_name != null && length(rule.source_address_prefixes) == 0) ||
        (rule.source_subnet_name == null && length(rule.source_address_prefixes) > 0)
        )
      ]
    ]))
    error_message = "inbound_rules: source_subnet_name and destination_address_prefixes are mutually exclusive"
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten([
      for nsg in var.custom_security_group : [
        for rule in nsg.outbound_rules : (
          (rule.destination_subnet_name != null && rule.destination_subnet_vnet_name != null) ||
        (rule.destination_subnet_name == null && rule.destination_subnet_vnet_name  == null)
        )
      ]
    ]))
    error_message = "outbound_rules: destination_subnet_name and destination_subnet_vnet_name must both be defined or both be null"
  }

  validation {
    condition = var.custom_security_group == null ? true : alltrue(flatten([
      for nsg in var.custom_security_group : [
        for rule in nsg.inbound_rules : (
           (rule.source_subnet_name != null && rule.source_subnet_vnet_name != null) ||
        (rule.source_subnet_name == null && rule.source_subnet_vnet_name  == null)
        )
      ]
    ]))
    error_message = "inbound_rules: source_subnet_name and source_subnet_vnet_name must both be defined or both be null"
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

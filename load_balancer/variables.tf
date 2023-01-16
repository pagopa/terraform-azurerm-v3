variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where the load balancer resources will be imported."
  type        = string
}

variable "lb_port" {
  description = "Protocols to be used for lb rules. Format as name => {frontend_port, protocol, backend_port, backend_pool_name, probe_name}"
  type = map(object({
    frontend_port     = string
    protocol          = string
    backend_port      = string
    backend_pool_name = string
    probe_name        = string
  }))
  default = {}
}

variable "lb_probe_unhealthy_threshold" {
  description = "Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  type        = number
  default     = 2
}

variable "lb_probe_interval" {
  description = "Interval in seconds the load balancer health probe rule does a check"
  type        = number
  default     = 5
}

variable "frontend_name" {
  description = "(Required) Specifies the name of the frontend ip configuration."
  type        = string
  default     = "LoadBalancerFrontEnd"
}

variable "allocation_method" {
  description = "(Required) Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Static"
}

variable "tags" {
  type = map(string)

  default = {
    source = "terraform"
  }
}

variable "type" {
  description = "(Optional) Defined if the loadbalancer is private or public"
  type        = string
  default     = "public"
}

variable "frontend_subnet_id" {
  description = "(Optional) Frontend subnet id to use when in private mode"
  type        = string
  default     = ""
}

variable "frontend_private_ip_address" {
  description = "(Optional) Private ip address to assign to frontend. Use it with type = private"
  type        = string
  default     = ""
}

variable "frontend_private_ip_address_allocation" {
  description = "(Optional) Frontend ip allocation type (Static or Dynamic)"
  type        = string
  default     = "Dynamic"
}

variable "lb_sku" {
  description = "(Optional) The SKU of the Azure Load Balancer. Accepted values are Basic and Standard."
  type        = string
  default     = "Basic"
}

variable "lb_probe" {
  description = "(Optional) Protocols to be used for lb health probes. Format as name => {protocol, port, request_path}"
  type = map(object({
    protocol     = string
    port         = string
    request_path = string
  }))
  default = {}
}

variable "lb_backend_pools" {
  description = "(Optional) Backend pool and ip address configuration"
  type = list(object(
    {
      name = string
      ips = list(object(
        {
          ip      = string
          vnet_id = string
      }))
  }))
  default = [
    {
      name = "default"
      ips  = []
    }
  ]
}

variable "pip_sku" {
  description = "(Optional) The SKU of the Azure Public IP. Accepted values are Basic and Standard."
  type        = string
  default     = "Basic"
}

variable "name" {
  description = "Name of the load balancer."
  type        = string
}

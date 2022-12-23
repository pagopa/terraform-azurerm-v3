variable "name" {
  type        = string
  description = "(Required) Resource name"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Resource location."
}

variable "sku_name" {
  type        = string
  description = "Sku type, at the moment only allowed value is Consumption"
  default = "Consumption"
}

variable "vnet_internal" {
  type        = bool
  description = "Virtual network integration"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id if container environment is in a virtual network"
}

variable "outbound_type" {
  type        = string
  description = "Outbound connectivity type, at the moment only allowed value is LoadBalancer"
  default = "LoadBalancer"
}

variable "log_destination" {
  type        = string
  description = "How to send container environment logs"
  # default = "log-analytics"
}

variable "log_analytics_customer_id" {
  type        = string
  description = "Workspace ID if log_destination is log-analytics type"
}

variable "log_analytics_shared_key" {
  type        = string
  description = "Workspace ID if log_destination is log-analytics type"
}

variable "zone_redundant" {
  type        = bool
  description = "Deploy multi zone container environment"
}

variable "tags" {
  type = map(any)
}

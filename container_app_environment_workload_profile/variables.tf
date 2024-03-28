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

variable "subnet_id" {
  type        = string
  description = "(Optional) Subnet id if the environment is in a custom virtual network"

  default = null
}

variable "zone_redundant" {
  type        = bool
  description = "Deploy multi zone environment. Can be true only if a subnet_id is provided"
  default     = false
}

variable "internal_load_balancer" {
  type        = bool
  description = "Internal Load Balancing Mode. Can be true only if a subnet_id is provided"
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace resource id"
}

variable "tags" {
  type = map(any)
}

variable "application_insights_connection_string" {
  type      = string
  sensitive = true
}

variable "workload_profiles" {
  type = list(object({
    name                = string
    workloadProfileType = string

    # maximumCount = int
    # minimumCount = int
    # name = "string"
    # workloadProfileType = "string"
  }))
}

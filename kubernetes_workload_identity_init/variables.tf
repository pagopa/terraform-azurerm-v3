locals {
  workload_identity_name = var.workload_identity_name != null ? var.workload_identity_name : "${var.workload_identity_name_prefix}-workload-identity"
}

variable "workload_identity_name_prefix" {
  type        = string
  description = "(Required) The name prefix of the user assigned identity and Workload identity. Changing this forces a new identity to be created."
}

variable "workload_identity_name" {
  type        = string
  description = "(Optional) The full name for the user assigned identity and Workload identity. Changing this forces a new identity to be created."
  default     = null
}

variable "workload_identity_resource_group_name" {
  type        = string
  description = "(Required) Specifies the name of the Resource Group within which this User Assigned Identity should exist. Changing this forces a new User Assigned Identity to be created."
}

variable "workload_identity_location" {
  type        = string
  description = "(Required) The Azure Region where the User Assigned Identity should exist. Changing this forces a new User Assigned Identity to be created."
}

variable "enable_lock" {
  type        = bool
  description = "Allow to enable of disable lock for managed identity"
  default     = true
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type    = string
  default = null
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "terraform_cloud_object_id" {
  type        = string
  default     = null
  description = "Terraform cloud object id to create its access policy."
}

variable "lock_enable" {
  type        = bool
  default     = false
  description = "Apply lock to block accedentaly deletions."
}

variable "sec_log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log analytics workspace security (it should be in a different subscription)."
}

variable "sec_storage_id" {
  type        = string
  default     = null
  description = "Storage Account security (it should be in a different subscription)."
}

variable "soft_delete_retention_days" {
  type        = number
  default     = 15
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
}

variable "enable_rbac_authorization" {
  type        = bool
  default     = false
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Boolean flag to specify whether Azure Key Vault use public access."
}

variable "tags" {
  type = map(any)
}

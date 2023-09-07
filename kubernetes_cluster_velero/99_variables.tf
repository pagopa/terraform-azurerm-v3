variable "tags" {
  type = map(any)
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the resource group in which the backup storage account is located"
}


variable "backup_storage_container_name" {
  type        = string
  description = "(Required) Name of the storage container where Velero keeps the backups"
}

variable "aks_cluster_name" {
  type        = string
  description = "(Required) Name of the aks cluster on which Velero will be installed"
}

variable "aks_cluster_rg" {
  type        = string
  description = "(Required) AKS cluster resource group name"
}

variable "subscription_id" {
  type        = string
  description = "(Required) ID of the subscription"
}

variable "tenant_id" {
  type        = string
  description = "(Required) ID of the tenant"
}

variable "plugin_version" {
  type        = string
  description = "(Optional) Version for the velero plugin"
  default     = "v1.7.1"
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix used in the Velero dedicated resource names"
}


variable "location" {
  type        = string
  description = "(Required) Resource location"
}

variable "storage_account_private_dns_zone_id" {
  type        = string
  description = "(Optional) Storage account private dns zone id, used in the private endpoint creation"
  default     = null
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "(Optional) Subnet id where to create the private endpoint for backups storage account"
  default     = null
}

variable "use_storage_private_endpoint" {
  type        = bool
  description = "(Optional) Whether to make the storage account private and use a private endpoint to connect"
  default     = true
}

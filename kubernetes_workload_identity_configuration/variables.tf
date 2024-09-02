variable "workload_name_prefix" {
  type        = string
  description = "(Required) The name prefix of the user assigned identity and Workload identity. Changing this forces a new identity to be created."
}

variable "workload_identity_name" {
  type        = string
  description = "(Required) The full name for the user assigned identity and Workload identity. Changing this forces a new identity to be created."
}

variable "workload_identity_resource_group_name" {
  type        = string
  description = "(Required) Resource group for the workload identity."
}

#
# AKS
#

variable "aks_resource_group_name" {
  type        = string
  description = "(Required) Resource group of the Kubernetes cluster."
}

variable "aks_name" {
  type        = string
  description = "(Required) Name of the Kubernetes cluster."
}

variable "namespace" {
  type        = string
  description = "(Required) Kubernetes namespace where the pod identity will be create."
}

variable "service_account_configuration_enabled" {
  type        = string
  description = "(Optional) Enabled the service account configuration"
  default     = true
}

variable "service_account_annotations" {
  type        = map(string)
  description = "(Optional) More annotations for service account"
  default     = {}
}

variable "service_account_labels" {
  type        = map(string)
  description = "(Optional) More Labels for service account"
  default     = {}
}

variable "service_account_image_pull_secret_names" {
  type        = set(string)
  description = "(Optional) Sets of image pull secert names"
  default     = []
}

#
# Key Vault Permissions
#
variable "key_vault_id" {
  type        = any
  description = "(Required) Specifies the id of the Key Vault resource. Changing this forces a new resource to be created."
}

variable "key_vault_secret_permissions" {
  type        = list(string)
  description = "(Required) API permissions of the identity to access secrets, must be one or more from the following: Backup, Delete, Get, List, Purge, Recover, Restore and Set."
}

variable "key_vault_key_permissions" {
  type        = list(string)
  description = "(Required) API permissions of the identity to access keys, must be one or more from the following: Backup, Create, Decrypt, Delete, Encrypt, Get, Import, List, Purge, Recover, Restore, Sign, UnwrapKey, Update, Verify and WrapKey."
}

variable "key_vault_certificate_permissions" {
  type        = list(string)
  description = "(Required) API permissions of the identity to access certificates, must be one or more from the following: Backup, Create, Delete, DeleteIssuers, Get, GetIssuers, Import, List, ListIssuers, ManageContacts, ManageIssuers, Purge, Recover, Restore, SetIssuers and Update."
}

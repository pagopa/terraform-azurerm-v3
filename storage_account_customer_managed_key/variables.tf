variable "tenant_id" {
  type    = string
  default = null
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "key_vault_id" {
  description = "The id of the keyvault containing the customer key to use for encryption"
  type        = string
}

variable "key_name" {
  description = "The arbitrary name of the key that will be created in the key vault"
  type        = string
}

variable "storage_id" {
  description = "The target storage account id (e.g. azurerm_storage_account.example.id )"
  type        = string
}

variable "storage_principal_id" {
  description = "The target storage account principal (e.g. azurerm_storage_account.example.identity.0.principal_id )"
  type        = string
}

#### OPTIONAL ####

variable "key_size" {
  description = "The RSA key size (2048, 3072, 4096)"
  type        = number
  default     = 4096
}


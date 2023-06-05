variable "namespace" {
  type        = string
  description = "(Required) Namespace where the cert secret will be created"
}

variable "certificate_name" {
  type        = string
  description = "(Required) Name of the certificate stored in the keyvault, that will be installed as a secret in aks"
}

variable "kv_name" {
  type        = string
  description = "(Required) Key vault name where to retrieve the certificate"
}

variable "tenant_id" {
  type        = string
  description = "(Required) Tenant identifier"
}


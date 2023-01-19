variable "balancer_node_number" {
  description = "Number of balancer nodes"
  type        = string
  default     = "0"
}

variable "master_node_number" {
  description = "Number of master nodes"
  type        = string
  default     = "1"
}

variable "hot_node_number" {
  description = "Number of hot nodes"
  type        = string
  default     = "1"
}

variable "warm_node_number" {
  description = "Number of warm nodes"
  type        = string
  default     = "0"
}

variable "cold_node_number" {
  description = "Number of cold nodes"
  type        = string
  default     = "0"
}

variable "balancer_storage_size" {
  description = "Storage size of balancer node in GB"
  type        = string
  default     = "0"
}

variable "master_storage_size" {
  description = "Storage size of master node in GB"
  type        = string
  default     = "20"
}

variable "hot_storage_size" {
  description = "Storage size of hot node in GB"
  type        = string
  default     = "50"
}

variable "warm_storage_size" {
  description = "Storage size of warm node in GB"
  type        = string
  default     = "0"
}

variable "cold_storage_size" {
  description = "Storage size of cold node in GB"
  type        = string
  default     = "0"
}

variable "balancer_storage_class" {
  description = "Storage class of balancer node in GB"
  type        = string
}

variable "master_storage_class" {
  description = "Storage class of master node in GB"
  type        = string
}

variable "hot_storage_class" {
  description = "Storage class of hot node in GB"
  type        = string
}

variable "warm_storage_class" {
  description = "Storage class of warm node in GB"
  type        = string
}

variable "cold_storage_class" {
  description = "Storage class of cold node in GB"
  type        = string
}

variable "kibana_external_domain" {
  description = "Kibana external domain"
  type        = string
}

variable "secret_name" {
  description = "Secret certificate name"
  type        = string
}

variable "keyvault_name" {
  description = "Keyvault name"
  type        = string
}

variable "kibana_internal_hostname" {
  description = "Kibana internal hostname"
  type        = string
}
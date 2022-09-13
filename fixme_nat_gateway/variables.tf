variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "zone" {
  type        = string
  default     = "1"
  description = "Availability zone where the NAT Gateway should be provisioned."
}

variable "idle_timeout_in_minutes" {
  type        = number
  description = "The idle timeout which should be used in minutes."
  default     = 4
}

variable "sku_name" {
  type        = string
  description = "The SKU which should be used. At this time the only supported value is Standard."
  default     = "Standard"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnets id to which associate the nat gateway"
}

variable "public_ips_count" {
  type        = number
  default     = 1
  description = "Number of public ips associated to the nat gateway"
}

variable "tags" {
  type = map(any)
}
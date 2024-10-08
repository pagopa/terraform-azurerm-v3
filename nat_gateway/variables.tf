variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

# NAT Gateway not support multiple availability zones
# Public IPs must be in the same availability zones of NAT Gateway
variable "zones" {
  type        = list(number)
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

variable "additional_public_ip_ids" {
  type = list(string)
  default = []
  description = "(Optional) list of additional public ip ids to associate to the nat gw"
}

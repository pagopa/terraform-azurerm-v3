variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "api_key_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable the api key setting of the Grafana instance"
}

variable "deterministic_outbound_ip_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable the Grafana instance to use deterministic outbound IPs"
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable traffic over the public interface"

}

variable "identity_type" {
  type    = string
  default = "SystemAssigned"
}

variable "sku" {
  type        = string
  description = "The name of the SKU used for the Grafana instance. The only possible value is Standard. Defaults to Standard. Changing this forces a new Dashboard Grafana to be created"
  default     = "Standard"
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Whether to enable the zone redundancy setting of the Grafana instance"
  default     = false
}

## App service
variable "app_service_id" {
  type        = string
  description = "(Required) The id of the App Service within which to create the App Service Slot."
}

variable "https_only" {
  type        = bool
  description = "(Optional) Can the App Service only be accessed via HTTPS? Defaults to true."
  default     = true
}

variable "client_certificate_enabled" {
  type        = bool
  description = "Should the function app use Client Certificates"
  default     = false
}

variable "client_affinity_enabled" {
  type        = bool
  description = "(Optional) Should the App Service send session affinity cookies, which route client requests in the same session to the same instance? Defaults to false."
  default     = false
}

## App service slot
variable "name" {
  type        = string
  description = "(Required) Specifies the name of the App Service. Changing this forces a new resource to be created."
}

variable "use_32_bit_worker_process" {
  type        = bool
  description = "(Optional) Should the App Service Slot run in 32 bit mode, rather than 64 bit mode? Defaults to false."
  default     = false
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "always_on" {
  type        = bool
  description = "(Optional) Should the app be loaded at all times? Defaults to false."
  default     = false
}

variable "app_command_line" {
  type        = string
  description = "(Optional) App command line to launch, e.g. /sbin/myserver -b 0.0.0.0."
  default     = null
}

variable "ftps_state" {
  type        = string
  description = "(Optional) Enable FTPS connection ( Default: Disabled )"
  default     = "Disabled"
}

variable "health_check_path" {
  type        = string
  description = "(Optional) The health check path to be pinged by App Service."
  default     = null
}

variable "allowed_subnets" {
  type        = list(string)
  description = "(Optional) List of subnet allowed to call the appserver endpoint."
  default     = []
}

variable "allowed_ips" {
  type        = list(string)
  description = "(Optional) List of ips allowed to call the appserver endpoint."
  default     = []
}

variable "vnet_integration" {
  type        = bool
  description = "(optional) enable vnet integration. Wheter it's true the subnet_id should not be null."
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "(Optional) Subnet id wether you want to integrate the app service to a subnet."
  default     = null
}

variable "tags" {
  type = map(any)
}

# Framework choice
variable "docker_image" {
  type    = string
  default = null
}
variable "docker_image_tag" {
  type    = string
  default = null
}
variable "dotnet_version" {
  type    = string
  default = null
}
variable "go_version" {
  type    = string
  default = null
}
variable "java_server" {
  type    = string
  default = null
}
variable "java_server_version" {
  type    = string
  default = null
}
variable "java_version" {
  type    = string
  default = null
}
variable "node_version" {
  type    = string
  default = null
}
variable "php_version" {
  type    = string
  default = null
}
variable "python_version" {
  type    = string
  default = null
}
variable "ruby_version" {
  type    = string
  default = null
}
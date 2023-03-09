variable "location" {
  type        = string
  default     = "westeurope"
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the App Service and App Service Plan."
}

## App service plan

variable "plan_type" {
  type        = string
  description = "(Required) Specifies if app service plan is external or internal"
  validation {
    condition = (
      var.plan_type == "internal" ||
      var.plan_type == "external"
    )
    error_message = "Plan type can be only internal or external."
  }
  default = "internal"
}

variable "plan_id" {
  type        = string
  description = "(Optional only if plan_type=internal) Specifies the external app service plan id."
  default     = null
}

variable "plan_name" {
  type        = string
  description = "(Optional) Specifies the name of the App Service Plan component. Changing this forces a new resource to be created."
  default     = null
}

variable "plan_kind" {
  type        = string
  description = "(Optional) The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan). Changing this forces a new resource to be created."
  default     = null
}

variable "sku_name" {
  type        = string
  description = "(Required) The SKU for the plan."
  default     = null
}

variable "plan_maximum_elastic_worker_count" {
  type        = number
  description = "(Optional) The maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan."
  default     = null
}

variable "plan_per_site_scaling" {
  type        = bool
  description = "(Optional) Can Apps assigned to this App Service Plan be scaled independently? If set to false apps assigned to this plan will scale to all instances of the plan. Defaults to false."
  default     = false
}

## App service

variable "name" {
  type        = string
  description = "(Required) Specifies the name of the App Service. Changing this forces a new resource to be created."
}

variable "https_only" {
  type        = bool
  description = "(Optional) Can the App Service only be accessed via HTTPS? Defaults to true."
  default     = true
}

variable "use_32_bit_worker_process" {
  type        = bool
  description = "(Optional) Should the Function App run in 32 bit mode, rather than 64 bit mode? Defaults to false."
  default     = false
}

variable "client_affinity_enabled" {
  type        = bool
  description = "(Optional) Should the App Service send session affinity cookies, which route client requests in the same session to the same instance? Defaults to false."
  default     = false
}

variable "client_cert_enabled" {
  type        = bool
  description = "(Optional) Does the App Service require client certificates for incoming requests? Defaults to false."
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
variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group name."
}

variable "location" {
  type = string
}

variable "location_short" {
  type = string
  validation {
    condition = (
      length(var.location_short) == 3
    )
    error_message = "Length must be 3 chars."
  }
  description = "One of wue, neu"
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "monitor_workspace_name" {
  description = "Name for the Azure Monitor Workspace."
  type        = string
  default     = "MonitorWorkspace"
}

variable "monitor_workspace_rg" {
  description = "Name for the Azure Monitor Workspace Resource Group."
  type        = string
  default     = "MonitorWorkspaceRG"
}

variable "cluster_region" {
  description = "The Azure region of the Kubernetes cluster."
  type        = string
  default     = "westeurope"
}

variable "amw_region" {
  description = "The Azure region where the Monitor Workspace is deployed."
  type        = string
  default     = "westeurope"
}

variable "is_private_cluster" {
  description = "Boolean to determine if the cluster is private."
  type        = bool
  default     = false
}

variable "grafana_name" {
  description = "The name for the Azure Managed Grafana instance."
  type        = string
}

variable "grafana_resource_group" {
  description = "(Required) Name of the resource group where resource belongs to."
  type        = string
}

variable "custom_gf_location" {
  description = "The Azure region where Grafana is deployed."
  type        = string
  default     = null
}

variable "action_groups_id" {
  description = "The ID of the Action Group to use for the Alerts."
  type        = list(string)
  default     = []
}

variable "enable_prometheus_alerts" {
  description = "Enable/Disable Prometheus Alerts."
  type        = bool
  default     = true
}

variable "enable_alerts" {
  description = "Enable/Disable Alerts Rules on Azure Monitor."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group name."
}

variable "location" {
  type = string
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
}

variable "tags" {
  type = map(any)
}

variable "monitor_workspace_name" {
  description = "Name for the Azure Monitor Log Analytics Workspace."
  type        = string
  default     = "myMonitorWorkspace"
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

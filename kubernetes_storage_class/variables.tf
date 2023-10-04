#
# Kubernetes Cluster Configurations
#
variable "k8s_kube_config_path_prefix" {
  type        = string
  default     = "~/.kube"
  description = "(Optional) Path to kube config files"
}

variable "aks_cluster_name" {
  type        = string
  description = "(Required) Cluster name where these storage classes will be created"
}

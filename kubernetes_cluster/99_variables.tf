variable "name" {
  type        = string
  description = "(Required) Cluster name"
}

variable "dns_prefix" {
  type        = string
  description = "(Required) DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Resource group name."
}

variable "location" {
  type = string
}

variable "aad_admin_group_ids" {
  description = "IDs of the Azure AD group for cluster-admin access"
  type        = list(string)
}

#
# Default node pool
#

variable "system_node_pool_name" {
  type        = string
  description = "(Required) The name which should be used for the default Kubernetes Node Pool. Changing this forces a new resource to be created."
  validation {
    condition = (
      length(var.system_node_pool_name) <= 12
    )
    error_message = "Max length is 12 chars."
  }
}

variable "system_node_pool_vm_size" {
  type        = string
  description = "(Required) The size of the Virtual Machine, such as Standard_B4ms or Standard_D4s_vX. See https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/134840344/Best+practice+su+prodotti"
}

variable "system_node_pool_os_disk_type" {
  type        = string
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed."
  default     = "Ephemeral"
}

variable "system_node_pool_os_disk_size_gb" {
  type        = number
  description = "(Optional) The size of the OS Disk which should be used for each agent in the Node Pool. Changing this forces a new resource to be created."
}

variable "system_node_pool_node_count_min" {
  type        = number
  description = "(Required) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
}

variable "system_node_pool_node_count_max" {
  type        = number
  description = "(Required) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
}

variable "system_node_pool_max_pods" {
  type        = number
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  default     = 250
}

variable "system_node_pool_node_labels" {
  type        = map(any)
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created."
  default     = {}
}

variable "system_node_pool_enable_host_encryption" {
  type        = bool
  description = "(Optional) Should the nodes in the Default Node Pool have host encryption enabled? Defaults to true."
  default     = true
}

variable "system_node_pool_only_critical_addons_enabled" {
  type        = bool
  description = "(Optional) Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint. Changing this forces a new resource to be created."
  default     = true
}

variable "system_node_pool_ultra_ssd_enabled" {
  type        = bool
  description = "(Optional) Used to specify whether the UltraSSD is enabled in the Default Node Pool. Defaults to false."
  default     = false
}

variable "system_node_pool_availability_zones" {
  type        = list(string)
  description = "(Optional) List of availability zones for system node pool"
  default     = ["1", "2", "3"]
}

variable "system_node_pool_tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the Node Pool."
  default     = {}
}
### END SYSTEM NODE POOL

#
# User node pool
#
variable "user_node_pool_enabled" {
  type        = bool
  description = "Is user node pool enabled?"
  default     = false
}

variable "user_node_pool_name" {
  type        = string
  description = "(Required) The name which should be used for the default Kubernetes Node Pool. Changing this forces a new resource to be created."
  validation {
    condition = (
      length(var.user_node_pool_name) <= 12
    )
    error_message = "Max length is 12 chars."
  }
}

variable "user_node_pool_vm_size" {
  type        = string
  description = "(Required) The size of the Virtual Machine, such as Standard_B4ms or Standard_D4s_vX. See https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/134840344/Best+practice+su+prodotti"
}

variable "user_node_pool_os_disk_type" {
  type        = string
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed."
  default     = "Ephemeral"
}

variable "user_node_pool_os_disk_size_gb" {
  type        = number
  description = "(Optional) The size of the OS Disk which should be used for each agent in the Node Pool. Changing this forces a new resource to be created."
}

variable "user_node_pool_node_count_min" {
  type        = number
  description = "(Required) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
}

variable "user_node_pool_node_count_max" {
  type        = number
  description = "(Required) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
}

variable "user_node_pool_max_pods" {
  type        = number
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  default     = 250
}

variable "user_node_pool_node_labels" {
  type        = map(any)
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created."
  default     = {}
}

variable "user_node_pool_node_taints" {
  type        = list(string)
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  default     = []
}

variable "user_node_pool_enable_host_encryption" {
  type        = bool
  description = "(Optional) Should the nodes in the Default Node Pool have host encryption enabled? Defaults to true."
  default     = false
}

variable "user_node_pool_ultra_ssd_enabled" {
  type        = bool
  description = "(Optional) Used to specify whether the UltraSSD is enabled in the Default Node Pool. Defaults to false."
  default     = false
}

variable "user_node_pool_availability_zones" {
  type        = list(string)
  description = "(Optional) List of availability zones for user node pool"
  default     = ["1", "2", "3"]
}

variable "user_node_pool_tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the Node Pool."
  default     = {}
}
### END USER NODE POOL

variable "upgrade_settings_max_surge" {
  type        = string
  description = "The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade."
  default     = "33%"
}

variable "sku_tier" {
  type        = string
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA)"
  default     = "Free"
}

variable "kubernetes_version" {
  type        = string
  description = "(Required) Version of Kubernetes specified when creating the AKS managed cluster."
}

#
# Network
#
variable "private_cluster_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located."
}

variable "vnet_id" {
  type        = string
  description = "(Required) Virtual network id, where the k8s cluster is deployed."
}

variable "vnet_subnet_id" {
  type        = string
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  default     = null
}
variable "vnet_user_subnet_id" {
  type        = string
  description = "(Optional) The ID of a Subnet where the Kubernetes User Node Pool should exist. Changing this forces a new resource to be created."
  default     = null
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none."
  default     = null
}

variable "network_profile" {
  type = object({
    dns_service_ip      = optional(string, "10.2.0.10")    # e.g. '10.2.0.10'. IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)
    network_policy      = optional(string, "azure")        # e.g. 'azure'. Sets up network policy to be used with Azure CNI. Currently supported values are calico and azure.
    network_plugin      = optional(string, "azure")        # e.g. 'azure'. Network plugin to use for networking. Currently supported values are azure and kubenet
    network_plugin_mode = optional(string, null)           # e.g. 'azure'. Network plugin mode to use for networking. Currently supported value is overlay
    outbound_type       = optional(string, "loadBalancer") # e.g. 'loadBalancer'. The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer, userDefinedRouting, managedNATGateway and userAssignedNATGateway. Defaults to loadBalancer
    service_cidr        = optional(string, "10.2.0.0/16")  # e.g. '10.2.0.0/16'. The Network Range used by the Kubernetes service
  })
  default = {
    dns_service_ip = "10.2.0.10"
    network_policy = "azure"
    network_plugin = "azure"
    outbound_type  = "loadBalancer"
    service_cidr   = "10.2.0.0/16"
  }
  description = "See variable description to understand how to use it, and see examples"
}

variable "outbound_ip_address_ids" {
  type        = list(string)
  default     = []
  description = "The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer."
}

#
# addons
#
variable "addon_azure_policy_enabled" {
  type        = bool
  description = "Should the Azure Policy addon be enabled for this Node Pool? "
  default     = false
}

variable "addon_azure_key_vault_secrets_provider_enabled" {
  type        = bool
  description = "Should the Azure Secrets Store CSI addon be enabled for this Node Pool? "
  default     = false
}

variable "addon_azure_pod_identity_enabled" {
  type        = bool
  description = "Should the AAD pod-managed identities be enabled for this Node Pool? "
  default     = false
}

#
# Logs
#
variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace which the OMS Agent should send data to."
  default     = null
}

variable "microsoft_defender_log_analytics_workspace_id" {
  type        = string
  description = "Specifies the ID of the Log Analytics Workspace where the audit logs collected by Microsoft Defender should be sent to"
  default     = null
}

variable "sec_log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log analytics workspace security (it should be in a different subscription)."
}

variable "sec_storage_id" {
  type        = string
  default     = null
  description = "Storage Account security (it should be in a different subscription)."
}

variable "tags" {
  type = map(any)
}

variable "workload_identity_enabled" {
  type        = bool
  description = "(Optional) Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to false."
  default     = false
}

variable "oidc_issuer_enabled" {
  type        = bool
  description = "(Optional) Enable or Disable the OIDC issuer URL"
  default     = false
}

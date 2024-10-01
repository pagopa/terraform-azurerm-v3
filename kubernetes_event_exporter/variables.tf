locals {
  helm_chart_name = "kubernetes-event-exporter"
}

#
# 🪖 HELM & Kubernetes
#
variable "namespace" {
  type        = string
  description = "(Required) Namespace where the helm chart will be installed"
  default     = "default"
}

variable "helm_chart_present" {
  type        = bool
  description = "Is this helm chart present?"
  default     = true
}

variable "helm_chart_version" {
  type        = string
  description = "Helm chart version for the kubernetes-event-exporter application"
  default     = "3.2.12"
}

variable "custom_config" {
  type        = string
  description = "(Optional) Use this param to deploy a custom ConfigMap on exporter services"
  default     = null
}

variable "custom_variables" {
  type = map(string)
  default     = null
  description = "(Optional) This maps contains the custom variable declare by the user on the custom_config"
}

#
# 💬 SLACK Parameters
#

variable "enable_slack" {
  type        = bool
  description = "(Optional) Enable slack integration to send alert on your dedicated channel."
  default     = true
}

variable "slack_receiver_name" {
  type        = string
  description = "(Optional) Set custom receiver name for slack integration."
  default     = "slack"
}

variable "slack_token" {
  type        = string
  description = "(Optional) Slack app token to be able to connect on your workspace and send messages."
}

variable "slack_channel" {
  type        = string
  description = "(Optional) Slack channel for receive messages from exporter."
}

variable "slack_message_prefix" {
  type        = string
  description = "(Optional) Formatting the message prefix of your slack alert."
  default     = "Received a Kubernetes Event:"
}

variable "slack_title" {
  type        = string
  description = "(Optional) The name of message title of your app."
  default     = "kubernetes event exporter app"
}

variable "slack_author" {
  type        = string
  description = "(Optional) The name of author to display on slack message sent."
  default     = "kubexporter"
}

#
# 👷🏻‍♂️OPSGENIE Parameters
#

variable "enable_opsgenie" {
  type        = bool
  description = "(Optional) Flag to enable opsgenie integration."
  default     = false
}

variable "opsgenie_receiver_name" {
  type        = string
  description = "(Optional) Set custom receiver name for opsgenie integration."
  default     = "opsgenie"
}

variable "opsgenie_api_key" {
  type        = string
  description = "(Optional) OpsGenie API token required for integration https://support.atlassian.com/opsgenie/docs/create-a-default-api-integration/"
  default     = ""
}


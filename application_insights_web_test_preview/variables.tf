variable "subscription_id" {
  type        = string
  description = "(Required) subscription id."
}

variable "name" {
  type        = string
  description = "(Required) Web test name"
}

variable "resource_group" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Application insight location."
}

variable "application_insight_name" {
  type        = string
  description = "Application insight instance name."
}

variable "application_insight_id" {
  type        = string
  description = "Application insight id."
}

variable "alert_description" {
  type        = string
  description = "Web Availability Alert description"
  default     = "Web availability check alert triggered when it fails."
}

variable "frequency" {
  type        = number
  description = "Interval in seconds between test runs for this WebTest."
  default     = 300
}

variable "timeout" {
  type        = number
  description = "Seconds until this WebTest will timeout and fail."
  default     = 30
}

variable "request_url" {
  type        = string
  description = "Url to check."

}

variable "expected_http_status" {
  type        = number
  description = "Expeced http status code."
  default     = 200
}

variable "ignore_http_status" {
  type        = bool
  description = "Ignore http status code."
  default     = false
}

variable "auto_mitigate" {
  type        = bool
  description = "(Optional) Should the alerts in this Metric Alert be auto resolved? Defaults to false."
  default     = false
}

variable "ssl_cert_remaining_lifetime_check" {
  type        = number
  description = "Days before the ssl certificate will expire. An expiry certificate will cause the test failing."
  default     = 7
}

variable "failed_location_count" {
  type        = number
  description = "The number of failed locations."
  default     = 1
}

variable "actions" {
  type = list(object({
    action_group_id = string
  }))
}

variable "severity" {
  type        = number
  description = "The severity of this Metric Alert."
  default     = 1
}

variable "content_validation" {
  type        = string
  description = "Required text that should appear in the response for this WebTest."
  default     = "null"
}

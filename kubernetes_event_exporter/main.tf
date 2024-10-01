resource "helm_release" "helm_this" {

  namespace        = var.namespace
  create_namespace = true
  name             = local.helm_chart_name
  chart            = "kubernetes-event-exporter"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = var.helm_chart_version
  timeout          = 120
  force_update     = true

  values = [
      var.custom_config == null ?
      templatefile("${path.module}/templates/default.tftpl",
        {
          enable_slack           = var.enable_slack, # SLACK PARAM BELOW
          slack_receiver_name    = var.slack_receiver_name,
          slack_token            = var.slack_token,
          slack_channel          = var.slack_channel,
          slack_message_prefix   = var.slack_message_prefix,
          slack_title            = var.slack_title,
          slack_author           = var.slack_author,
          enable_opsgenie        = var.enable_opsgenie, # OPSGENIE PARAM BELOW
          opsgenie_receiver_name = var.opsgenie_receiver_name,
          opsgenie_api_key       = var.opsgenie_api_key,
        }) :
      templatefile(var.custom_config, var.custom_variables)
  ]
}

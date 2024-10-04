
resource "random_id" "unique" {
  byte_length = 3
}

locals {
  project          = "${var.prefix}${substr(random_id.unique.hex, 0, 1)}"
  rg_name          = "${local.project}-${substr(random_id.unique.hex, 0, 1)}-rg"
  key_vault_name   = "${local.project}-kv"
  vnet_name        = "${local.project}-vnet"
  subnet_name      = "${local.project}-subnet"
  law_name         = "${local.project}-runner-law"
  environment_name = "${local.project}-runner-cae"
}

locals {
  product = "${var.prefix}-${var.env_short}"
  domain  = "synthetic"


  monitor_appinsights_name        = "${local.product}-appinsights"
  monitor_action_group_slack_name = "SlackPagoPA"
  monitor_action_group_email_name = "PagoPA"
  monitor_resource_group_name     = "${local.product}-monitor-rg"

  vnet_core_resource_group_name               = "${local.product}-vnet-rg"
  vnet_core_name                              = "${local.product}-vnet"
  log_analytics_workspace_name                = "${local.product}-law"
  log_analytics_workspace_resource_group_name = "${local.product}-monitor-rg"


}

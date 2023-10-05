locals {
  name                = "${var.prefix}-${var.env_short}"
  resource_group_name = "${local.name}-identity-rg"
}

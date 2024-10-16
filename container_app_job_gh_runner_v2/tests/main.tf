
resource "random_id" "unique" {
  byte_length = 3
}

locals {
  project          = "${var.prefix}${substr(random_id.unique.hex, 0, 1)}"
  rg_name          = "${local.project}-github-runner-rg"
  key_vault_name   = "${local.project}-kv"
  vnet_name        = "${local.project}-vnet"
  subnet_name      = "${local.project}-subnet"
  law_name         = "${local.project}-runner-law"
  environment_name = "${local.project}-runner-cae"
}

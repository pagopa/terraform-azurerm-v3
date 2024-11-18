# Domain setup for Azure Container App Job as GitHub Runners

This module relies on `container_app_job_gh_runner_v2` and other resources to create the necessary infrastructure to execute gh runner as container app jobs.
It creates a container app job for each defined repository, and then creates the required federated identity, federating it to each defined repo in order to be able to execute the gh actions.

## How to use it

```hcl 
module "gh_runner_domain" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//gh_runner_container_app_job_domain_setup?ref=v<version>"
  
  location = "westeurope"
  resource_group_name = "pagopa-d-weu-gpd-gh-identity-rg"
  prefix = "pagopa-d-weu-gpd"
  

  tags = var.tags
} 

```

locals {
  prefix                       = "${var.resource_prefix}"
  private_subnets_cidr         = [cidrsubnet(var.cidr_block, 3, 0), cidrsubnet(var.cidr_block, 3, 1)]
  public_subnets_cidr      = [cidrsubnet(var.cidr_block, 3, 2), cidrsubnet(var.cidr_block, 3, 3)]
  //firewall_public_subnets_cidr = [cidrsubnet(var.cidr_block, 3, 4)]
  sg_egress_ports              = [443, 3306, 6666]
  sg_ingress_protocol          = ["tcp", "udp"]
  sg_egress_protocol           = ["tcp", "udp"]
  //db_root_bucket               = "${var.resource_prefix}${random_string.naming.result}-rootbucket.s3.amazonaws.com"
}

provider "aws" {
  region = var.region
}

provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com"
  username = var.databricks_account_username
  password = var.databricks_account_password
}

output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}

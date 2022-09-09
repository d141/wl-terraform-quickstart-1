locals {
  prefix                       = var.resource_prefix
  owner                        = var.resource_owner
  cidr_block                   = var.cidr_block
  private_subnets_cidr         = [cidrsubnet(var.cidr_block, 3, 0), cidrsubnet(var.cidr_block, 3, 1)]
  public_subnets_cidr          = [cidrsubnet(var.cidr_block, 5, 2), cidrsubnet(var.cidr_block, 5, 3)]
  firewall_subnets_cidr        = [cidrsubnet(var.cidr_block, 5, 4), cidrsubnet(var.cidr_block, 5, 5)]
  privatelink_subnets_cidr     = [cidrsubnet(var.cidr_block, 5, 6), cidrsubnet(var.cidr_block, 5, 7)]
  sg_egress_ports              = [443, 3306, 6666]
  sg_ingress_protocol          = ["tcp", "udp"]
  sg_egress_protocol           = ["tcp", "udp"]
  availability_zones           = ["${var.region}a", "${var.region}b"]
  dbfsname                     = join("", [local.prefix, "-", var.region, "-", "dbfsroot"]) 
  uc_bucketname                = join("", [local.prefix, "-", var.region, "-", "unity-catalog"]) 
}

module "databricks_cmk" {
  source = "./modules/databricks_cmk"
  cross_account_role_arn = var.cross_account_role_arn
  resource_prefix        = local.prefix
  region                 = var.region
  cmk_admin              = var.cmk_admin
}

module "databricks_mws_workspace" {
  source = "./modules/databricks_workspace"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id  = var.databricks_account_id
  resource_prefix        = local.prefix
  security_group_ids     = [aws_security_group.sg.id]
  subnet_ids             = aws_subnet.private[*].id
  vpc_id                 = aws_vpc.dataplane_vpc.id
  cross_account_role_arn = var.cross_account_role_arn
  bucket_name            = aws_s3_bucket.root_storage_bucket.id
  workspace_storage_cmk  = module.databricks_cmk.workspace_storage_cmk
  managed_services_cmk   = module.databricks_cmk.managed_services_cmk
  region                 = var.region
}

// create PAT token to provision entities within workspace
resource "databricks_token" "pat" {
  provider         = databricks.created_workspace
  comment          = "Terraform Provisioning"
  lifetime_seconds = 86400
}
variable "databricks_account_username" {
     type = string
     sensitive = true
}

variable "databricks_account_password" {
     type = string
     sensitive = true
}

variable "databricks_account_id" {
     type = string
     sensitive = true
}

variable "iam_role_arn" {
     type = string
     sensitive = true
}

variable "resource_owner" {
  type = string
  sensitive = true
}

variable "cidr_block" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  default = {
    "Owner" = var.resource_owner
  }
}

variable "resource_prefix" {
  type = string
}

variable "workspace_vpce_service" {
    type = string
}

variable "relay_vpce_service" {
    type = string
}

variable "private_dns_enabled" { default = false }

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

terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }
  }
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
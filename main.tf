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

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "region" {
  default = "eu-west-2"
}

variable "tags" {
  default = {
    "Owner" = "andrew.weaver@databricks.com"
  }
}

variable "prefix" {
  default = "aweaver-ws"
}

variable "workspace_vpce_service" {
    default = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
}

variable "relay_vpce_service" {
    default = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
}

variable "private_dns_enabled" { default = false }

locals {
  prefix                       = "${var.prefix}"
  private_subnets_cidr         = [cidrsubnet(var.cidr_block, 3, 0), cidrsubnet(var.cidr_block, 3, 1)]
  public_subnets_cidr      = [cidrsubnet(var.cidr_block, 3, 2), cidrsubnet(var.cidr_block, 3, 3)]
  //firewall_public_subnets_cidr = [cidrsubnet(var.cidr_block, 3, 4)]
  sg_egress_ports              = [443, 3306, 6666]
  sg_ingress_protocol          = ["tcp", "udp"]
  sg_egress_protocol           = ["tcp", "udp"]
  //db_root_bucket               = "${var.prefix}${random_string.naming.result}-rootbucket.s3.amazonaws.com"
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

// Cross Account Role
resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  role_arn         = var.iam_role_arn
  credentials_name = "${local.prefix}-cross-account-role"
}

// DBFS Root
resource "aws_s3_bucket" "root_storage_bucket" {
  bucket = "${local.prefix}-rootbucket"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-rootbucket"
  })
}

resource "aws_s3_bucket_acl" "root_bucket_acls" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket                  = aws_s3_bucket.root_storage_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.root_storage_bucket]
}

data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.databricks_aws_bucket_policy.this.json
  depends_on = [aws_s3_bucket_public_access_block.root_storage_bucket]
}

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage_bucket.bucket
  storage_configuration_name = "${local.prefix}-root-bucket"
}

// Data Plane VPC
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "dataplane_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-dataplane-vpc"
  })
}

// Private Subnets
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.dataplane_vpc.id
  count                   = length(data.aws_availability_zones.available.names)
  cidr_block              = cidrsubnet(aws_vpc.dataplane_vpc.cidr_block, 3, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-private-${data.aws_availability_zones.available.names[count.index]}"
  })
}

// Public Subnet
resource "aws_subnet" "public" {

    vpc_id                  = aws_vpc.dataplane_vpc.id
    availability_zone       = data.aws_availability_zones.available.names[0]
    cidr_block              = cidrsubnet(aws_vpc.dataplane_vpc.cidr_block, length(data.aws_availability_zones.available.names)+6, 200)
    map_public_ip_on_launch = true
    tags = merge(var.tags, {
        Name = "${local.prefix}-${data.aws_availability_zones.available.names[0]}"
     })
}

// IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dataplane_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-igw"
  })
}

// EIP
resource "aws_eip" "ngw_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

// NGW
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_eip.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-nat"
  })
}

// SG
resource "aws_security_group" "sg" {
  name        = "${local.prefix}-sg"
  description = "Databricks Data Plane SG"
  vpc_id = aws_vpc.dataplane_vpc.id
  depends_on  = [aws_vpc.dataplane_vpc]

  dynamic "ingress" {
    for_each = local.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = local.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = local.sg_egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = var.tags
}

// Register Datbricks Network 
resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${local.prefix}-network"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids         = aws_subnet.private[*].id
  vpc_id             = aws_vpc.dataplane_vpc.id
}

// Private RT
resource "aws_route_table" "private_rt" {
  vpc_id             = aws_vpc.dataplane_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-private-rt"
  })
}

// Public RT
resource "aws_route_table" "public_rt" {
    vpc_id            = aws_vpc.dataplane_vpc.id
    tags  = merge(var.tags, {
    Name = "${local.prefix}-public-rt"
  })
}

// Private RT Associations
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

// Public RT Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public.id)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
  depends_on = [aws_subnet.public]
}

// Private Route
resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

// Public Route
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             =  aws_internet_gateway.igw.id
}

// VPC Endpoints
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = aws_vpc.dataplane_vpc.id
  security_group_ids = [aws_security_group.sg.id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        aws_route_table.private_rt.id
      ])
      tags = {
        Name = "${local.prefix}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.private[*].id
      tags = {
        Name = "${local.prefix}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.private[*].id
      tags = {
        Name = "${local.prefix}-kinesis-vpc-endpoint"
      }
    },
  }
  tags = var.tags
}

// Databricks Workspace
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = local.prefix

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id
  depends_on                 = [databricks_mws_networks.this]
  token {
    comment = "PAT for Terraform"
  }
}

output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}
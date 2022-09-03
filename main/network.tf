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
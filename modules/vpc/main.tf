locals {
  vpc_id   = aws_vpc.vpc.id
  tag_name = join("-", [var.environment, var.project])
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = join("-", [local.tag_name, "vpc"])
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = local.vpc_id
  cidr_block              = values(var.public_subnets)[count.index]
  availability_zone       = keys(var.public_subnets)[count.index]
  map_public_ip_on_launch = true

  tags = merge({
    Name = join("-", [local.tag_name, keys(var.public_subnets)[count.index], "public", "subnet"])
  }, var.common_tags, var.public_subnet_tags)

  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = values(var.private_subnets)[count.index]
  availability_zone = keys(var.private_subnets)[count.index]

  tags = merge({
    Name = join("-", [local.tag_name, keys(var.private_subnets)[count.index], "private", "subnet"])
  }, var.common_tags, var.private_subnet_tags)

  depends_on = [aws_vpc.vpc]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id

  tags = {
    Name = join("-", [local.tag_name, "ig"])
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_eip" "eip" {
  count = var.enable_private_subnet && length(var.private_subnets) > 0 && length(var.public_subnets) > 0 ? 1 : 0

  vpc = true

  tags = {
    Name = join("-", [local.tag_name, "eip"])
  }
  depends_on = [aws_vpc.vpc]
}

resource "aws_nat_gateway" "private" {
  count = var.enable_private_subnet && length(var.private_subnets) > 0 && length(var.public_subnets) > 0 ? 1 : 0

  allocation_id = aws_eip.eip[0].id
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name = join("-", [local.tag_name, "natgw"])
  }

  depends_on = [aws_eip.eip, aws_subnet.public]
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = join("-", [local.tag_name, "rt"])
  }

  depends_on = [aws_vpc.vpc, aws_internet_gateway.igw]
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id

  depends_on = [aws_vpc.vpc, aws_route_table.public]
}

resource "aws_route_table" "private" {
  count = var.enable_private_subnet && length(var.private_subnets) > 0 && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private[0].id
  }

  tags = {
    Name = join("-", [local.tag_name, "rt"])
  }

  depends_on = [aws_vpc.vpc, aws_subnet.private, aws_nat_gateway.private]
}

resource "aws_route_table_association" "private" {
  count = var.enable_private_subnet && length(var.private_subnets) > 0 && length(var.public_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[0].id

  depends_on = [aws_vpc.vpc, aws_route_table.private]
}
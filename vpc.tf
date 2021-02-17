resource "aws_vpc" "vpc_intranet" {
  cidr_block = var.cidr_vpc_intranet
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Environment = var.env
  }
}

resource "aws_subnet" "subnet_1" {
  cidr_block = var.cidr_intranet_subnet_1
  vpc_id = aws_vpc.vpc_intranet.id
  tags = {
    Environment = var.env
  }
}

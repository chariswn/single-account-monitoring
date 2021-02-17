variable "aws_region" {
  description = "AWS region"
  default = "ap-southeast-1"
}

variable "env" {
  description = "Environment"
  default = "test"
}

variable "cidr_vpc_intranet" {
  description = "Intranet VPC CIDR"
  default = "172.16.0.0/16"
}

variable "cidr_intranet_subnet_1" {
  description = "CIDR for Intranet Subnet 1"
  default = "172.16.10.0/26"
}

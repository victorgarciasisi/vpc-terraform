
variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Whether to use a single NAT gateway"
}


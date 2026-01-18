variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix"
  type        = string
}

variable "default_route_table_id" {
  description = "Default route table ID"
  type        = string
}


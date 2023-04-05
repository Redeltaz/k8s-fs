variable "aws_region" {
    type = string
    default = "eu-west-1"
}

variable "aws_profile" {
    type = string
}

variable "aws_owner" {
    type = string
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

variable "vpc_name" {
  type    = string
  default = "vpc-k8s-cluster"
}

variable "public_subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

variable "subnet_az" {
  type    = string
  default = "eu-west-1a"
}

variable "public_key_name" {
    type = string 
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

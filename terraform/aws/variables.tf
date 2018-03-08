variable "env_name" {
  type        = "string"
  description = "Short name of the environment used to prefix resources"
}

variable "aws_access_key" {
  type        = "string"
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = "string"
  description = "AWS secret key"
}

variable "aws_region" {
  type        = "string"
  description = "Name of the AWS region"
}

variable "aws_azs" {
  type        = "list"
  description = "Ordered list of the AWS AZs you want to use (max 3)"
}

variable "master_dns_domain_name" {
  type        = "string"
  description = "Zone name to integrate the subdomain into"
}

variable "dns_domain_name" {
  type        = "string"
  description = "Domain Name for this bootstrap environment"
}

variable "bootstrap_subnet" {
  type        = "string"
  description = "Subnet used to deploy the bootstrap environment, needs to be a /22"
}

variable "ssh_user" {
  type        = "string"
  default     = "ubuntu"
  description = "username used to ssh into the jumpbox"
}

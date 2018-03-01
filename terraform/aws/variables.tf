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

variable "aws_az_1" {
  type        = "string"
  description = "Name of the first az"
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
  description = "Subnet used to deploy the bootstrap environment, needs to be a /24"
}

variable "ssh_user" {
  type        = "string"
  default     = "ubuntu"
  description = "username used to ssh into the jumpbox"
}

variable "source_admin_networks" {
  type        = "list"
  default     = ["0.0.0.0/0"]
  description = "Admin networks whitelisted to ssh on the jumpbox"
}

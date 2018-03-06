variable "env_name" {
  type        = "string"
  description = "Short name of the environment used to prefix resources"
}

variable "gcp_project_name" {
  type        = "string"
  description = "Name of the GCP Project"
}

variable "gcp_key" {
  type        = "string"
  description = "GCP key"
}

variable "gcp_region" {
  type        = "string"
  description = "Name of the GCP region"
}

variable "gcp_zone_1" {
  type        = "string"
  description = "Zone used to deploy everything"
}

variable "master_dns_zone_name" {
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

variable "ha_concourse" {
  type        = "string"
  default     = "false"
  description = "whether you want your concourse HA or not : true/false"
}

variable "jumpbox_server_type" {
  type        = "string"
  default     = "n1-standard-1"
  description = "Server type for the jumpbox"
}

variable "natgw_server_type" {
  type        = "string"
  default     = "n1-standard-1"
  description = "Server type for the nat gateway"
}

variable "use_external_postgres" {
  type        = "string"
  default     = "false"
  description = "whether you want to use an GCP provided postgresDB for Concourse and it's dependecies"
}

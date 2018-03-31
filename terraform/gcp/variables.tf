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
  default     = "g1-small"
  description = "Server type for the jumpbox"
}

variable "natgw_server_type" {
  type        = "string"
  default     = "g1-small"
  description = "Server type for the nat gateway"
}

variable "use_external_postgres" {
  type        = "string"
  default     = "false"
  description = "whether you want to use an GCP provided postgresDB for Concourse and it's dependecies"
}

variable "gcp_zones" {
  type        = "list"
  description = "Ordered list of the gcp zones you want to use (max 3)"
}

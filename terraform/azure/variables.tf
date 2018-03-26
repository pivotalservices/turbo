variable "env_name" {
  type        = "string"
  description = "Short name of the environment used to prefix resources"
}

variable "arm_subscription_id" {
  type        = "string"
  description = "Azure Subscription ID"
}

variable "arm_tenant_id" {
  type        = "string"
  description = "Azure Tenant ID"
}

variable "arm_environment" {
  type        = "string"
  default     = "public"
  description = "Azure environment: public (default), usgovernment, german, china"
}

variable "arm_location" {
  type        = "string"
  description = "Azure location as listed here: https://azure.microsoft.com/en-us/global-infrastructure/regions/"
}

variable "arm_client_id" {
  type        = "string"
  description = "Azure Client ID"
}

variable "arm_client_secret" {
  type        = "string"
  description = "Azure Client Secret"
}

variable "master_dns_domain_name" {
  type        = "string"
  description = "Zone name to integrate the subdomain into"
}

variable "master_dns_domain_name_rg" {
  type        = "string"
  description = "Resource group where your master DNS zone sits"
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

variable "source_admin_networks" {
  type        = "list"
  default     = ["0.0.0.0/0"]
  description = "Admin networks whitelisted to ssh on the jumpbox"
}

variable "concourse_web_vm_type" {
  type        = "string"
  default     = "small"
  description = "Size of concourse web vms: small, medium, large, xlarge, 2xlarge"
}

variable "concourse_web_vm_count" {
  type        = "string"
  default     = "1"
  description = "Number of concourse web VMs to deploy"
}

variable "concourse_worker_vm_type" {
  type        = "string"
  default     = "medium"
  description = "Size of concourse web vms: medium, large, xlarge, 2xlarge, 4xlarge, 10xlarge, 16xlarge"
}

variable "concourse_worker_vm_count" {
  type        = "string"
  default     = "1"
  description = "Number of concourse worker VMs to deploy"
}

variable "credhub_uaa_vm_count" {
  type        = "string"
  default     = "1"
  description = "Number of credhub-uaa VMs to deploy"
}

variable "debug" {
  type        = "string"
  default     = "false"
  description = "if true, scripts will be run in debug mode (set -x)"
}

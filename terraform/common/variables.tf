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

variable "db_vm_type" {
  type        = "string"
  default     = "small"
  description = "Size of the postgres db vm: small, medium, large, xlarge, 2xlarge, 4xlarge, 10xlarge, 16xlarge"
}

variable "db_persistent_disk_size" {
  type        = "string"
  default     = "10"
  description = "Size of the DB disk in GB. Possible values: 10, 25, 50, 100, 250, 500, 1000"
}

variable "debug" {
  type        = "string"
  default     = "false"
  description = "if true, scripts will be run in debug mode (set -x)"
}

variable "deploy_metrics" {
  type        = "string"
  default     = "false"
  description = "if true, deploys grafana, riemann and influxdb to monitor your concourse"
}

variable "deployment_list" {
  type        = "list"
  default     = ["ucc"]
  description = "List of bosh deployments"
}

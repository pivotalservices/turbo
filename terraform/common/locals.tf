locals {
  env_base64 = "${base64encode(jsonencode(local.env))}"
}

locals {
  deployments_list = [
    # "credhub-uaa",
    # "concourse",
    "ucc",
  ]
}

locals {
  common_env = {
    TF_DEBUG = "${var.debug}"

    TF_CONCOURSE_WEB_VM_TYPE     = "${var.concourse_web_vm_type}"
    TF_CONCOURSE_WEB_VM_COUNT    = "${var.concourse_web_vm_count}"
    TF_CONCOURSE_WORKER_VM_TYPE  = "${var.concourse_worker_vm_type}"
    TF_CONCOURSE_WORKER_VM_COUNT = "${var.concourse_worker_vm_count}"
    TF_CREDHUB_UAA_VM_COUNT      = "${var.credhub_uaa_vm_count}"
    TF_DB_VM_TYPE                = "${var.db_vm_type}"
    TF_DB_PERSISTENT_DISK_SIZE   = "${var.db_persistent_disk_size}"

    TF_CONCOURSE_ADMIN_PASSWORD = "${random_string.concourse_password.result}"
    TF_CREDHUB_ADMIN_PASSWORD   = "${random_string.credhub_password.result}"
    TF_UAA_ADMIN_PASSWORD       = "${random_string.uaa_password.result}"
    TF_METRICS_ADMIN_PASSWORD   = "${random_string.metrics_password.result}"
  }

  common_flags = {
    metrics                   = "${var.deploy_metrics}"
    compiled_releaes          = "true"
    metrics_compiled_releases = "true"
    use_external_postgres     = "false"
  }
}

locals {
  env   = "${merge(local.common_env, local.iaas_env)}"
  flags = "${merge(local.common_flags, local.iaas_flags)}"
}

resource "random_string" "credhub_password" {
  length  = 30
  special = false
}

resource "random_string" "uaa_password" {
  length  = 30
  special = false
}

resource "random_string" "concourse_password" {
  length  = 30
  special = false
}

resource "random_string" "metrics_password" {
  length  = 30
  special = false
}

output "credhub_password" {
  value     = "${random_string.credhub_password.result}"
  sensitive = true
}

output "concourse_password" {
  value     = "${random_string.concourse_password.result}"
  sensitive = true
}

output "uaa_password" {
  value     = "${random_string.uaa_password.result}"
  sensitive = true
}

output "metrics_password" {
  value     = "${local.common_flags["metrics"] == "true" ? random_string.metrics_password.result : ""}"
  sensitive = true
}

output "environment_name" {
  value = "${var.env_name}"
}

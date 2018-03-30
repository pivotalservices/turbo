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
  turbo_home = "/home/${var.ssh_user}/turbo"
}

locals {
  common_env = {
    TF_TURBO_HOME = "${local.turbo_home}"

    TF_DEBUG         = "${var.debug}"
    TF_DIRECTOR_NAME = "turbo-director"
    TF_ENV_NAME      = "${var.env_name}"
    TF_FLAGS         = "${jsonencode(local.flags)}"
    TF_CPI           = "${local.iaas_type}"
    TF_STEMCELL_TYPE = "${local.stemcell}"

    TF_CONCOURSE_WEB_VM_TYPE     = "${var.concourse_web_vm_type}"
    TF_CONCOURSE_WEB_VM_COUNT    = "${var.concourse_web_vm_count}"
    TF_CONCOURSE_WORKER_VM_TYPE  = "${var.concourse_worker_vm_type}"
    TF_CONCOURSE_WORKER_VM_COUNT = "${var.concourse_worker_vm_count}"
    TF_DB_VM_TYPE                = "${var.db_vm_type}"
    TF_DB_PERSISTENT_DISK_SIZE   = "${var.db_persistent_disk_size}"

    TF_CONCOURSE_ADMIN_PASSWORD = "${random_string.concourse_password.result}"
    TF_CREDHUB_ADMIN_PASSWORD   = "${random_string.credhub_password.result}"
    TF_UAA_ADMIN_PASSWORD       = "${random_string.uaa_password.result}"
    TF_METRICS_ADMIN_PASSWORD   = "${random_string.metrics_password.result}"
    TF_JUMPBOX_SSH_KEY          = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
    TF_JUMPBOX_HOST             = "${local.ssh_host}"
  }

  common_flags = {
    metrics               = "${var.deploy_metrics}"
    use_external_postgres = "false"
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

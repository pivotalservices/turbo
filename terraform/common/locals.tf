locals {
  env_base64 = "${base64encode(jsonencode(local.env))}"
}

locals {
  deployments_list = [
    "credhub-uaa",
    "concourse",
  ]
}

locals {
  common_env = {
    TF_CONCOURSE_WEB_VM_TYPE    = "${var.concourse_web_vm_type}"
    TF_CONCOURSE_WORKER_VM_TYPE = "${var.concourse_worker_vm_type}"
  }
}

locals {
  env = "${merge(local.common_env, local.iaas_env)}"
}

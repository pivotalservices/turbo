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
    TF_CONCOURSE_WEB_VM_TYPE     = "${var.concourse_web_vm_type}"
    TF_CONCOURSE_WEB_VM_COUNT    = "${var.concourse_web_vm_count}"
    TF_CONCOURSE_WORKER_VM_TYPE  = "${var.concourse_worker_vm_type}"
    TF_CONCOURSE_WORKER_VM_COUNT = "${var.concourse_worker_vm_count}"
    TF_CREDHUB_UAA_VM_COUNT      = "${var.credhub_uaa_vm_count}"
  }
}

locals {
  env = "${merge(local.common_env, local.iaas_env)}"
}

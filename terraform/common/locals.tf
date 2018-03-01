locals {
  env_base64 = "${base64encode(jsonencode(local.env))}"
}

locals {
  deployments_list = [
    "credhub-uaa",
    "concourse",
  ]
}

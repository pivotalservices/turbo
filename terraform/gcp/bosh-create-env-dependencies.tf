resource "null_resource" "bosh_iaas_specific_dependencies" {
  depends_on = [
    "google_compute_instance.jumpbox",
  ]
}

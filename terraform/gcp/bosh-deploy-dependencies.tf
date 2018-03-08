resource "null_resource" "bosh_deploy_dependencies" {
  depends_on = [
    "google_compute_backend_service.concourse_web_lb_https_backend_service_1az",
    "google_compute_backend_service.credhub_lb_https_backend_service_1az",
    "google_compute_backend_service.uaa_lb_https_backend_service_1az",
  ]
}

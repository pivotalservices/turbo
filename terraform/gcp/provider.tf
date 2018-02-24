// Configure the Google Cloud provider
provider "google" {
  credentials = "${var.gcp_key}"
  project     = "${var.gcp_project_name}"
  region      = "${var.gcp_region}"
}

provider "google" {
  credentials = "${var.gcp_key}"
  project     = "${var.gcp_project_name}"
  region      = "${var.gcp_region}"
}

resource "google_storage_bucket" "tfstate_store" {
  name     = "${var.bucket_name}"
  location = "${var.bucket_location}"

  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = true
  }
}

variable "gcp_project_name" {
  type        = "string"
  description = "Name of the GCP Project"
}

variable "gcp_key" {
  type        = "string"
  description = "GCP key"
}

variable "gcp_region" {
  type        = "string"
  description = "Name of the GCP region"
}

variable "bucket_name" {
  type        = "string"
  default     = "tfstate-storage"
  description = "Name of the bucket that will store your tfstate files"
}

variable "bucket_location" {
  type        = "string"
  default     = "EU"
  description = "Location of the multi-regional bucket : EU, US, ASIA"
}

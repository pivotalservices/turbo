locals {
  "ssh_host"   = "${google_compute_address.jumpbox.address}"
  "jumpbox_id" = "${google_compute_instance.jumpbox.id}"
}

locals {
  stemcell  = "bosh-google-kvm-ubuntu-trusty-go_agent"
  iaas_type = "gcp"

  iaas_flags = {
    gcp_https_lb = "true"
  }
}

locals {
  concourse_dns = "${replace(google_dns_record_set.concourse-lb.name,"/\\.$/","")}"
  uaa_dns       = "${replace(google_dns_record_set.uaa-lb.name,"/\\.$/","")}"
  credhub_dns   = "${replace(google_dns_record_set.credhub-lb.name,"/\\.$/","")}"
  metrics_dns   = "${local.common_flags["metrics"] == "true" ? replace(join("", google_dns_record_set.metrics-lb.*.name),"/\\.$/","") : "" }"
}

locals {
  concourse_url = "https://${local.concourse_dns}"
  uaa_url       = "https://${local.uaa_dns}"
  credhub_url   = "https://${local.credhub_dns}:8844"

  metrics_url = "${local.common_flags["metrics"] == "true" ? format("https://%s", local.metrics_dns) : "" }"
}

locals {
  web_backend_service_name     = "${var.env_name}-concourse-https-lb-backend-${length(var.gcp_zones)}az"
  metrics_backend_service_name = "${var.env_name}-metrics-https-lb-backend-${length(var.gcp_zones)}az"
}

locals {
  iaas_env = {
    # Bosh
    GCP_CREDENTIALS_JSON = "${var.gcp_key}"
    TF_SSH_USER          = "${var.ssh_user}"
    TF_INTERNAL_CIDR     = "${google_compute_subnetwork.bosh.ip_cidr_range}"
    TF_INTERNAL_GW       = "${google_compute_subnetwork.bosh.gateway_address}"
    TF_INTERNAL_IP       = "${cidrhost(google_compute_subnetwork.bosh.ip_cidr_range, 6)}"
    TF_PROJECT_ID        = "${var.gcp_project_name}"
    TF_GCP_ZONES_COUNT   = "${length(var.gcp_zones)}"
    TF_AZ_LIST           = "${length(var.gcp_zones) == 1 ? "[z1]" :
                              length(var.gcp_zones) == 2 ? "[z1,z2]" : "[z1,z2,z3]"}"

    TF_GCP_ZONE_1 = "${var.gcp_zones[0]}"
    TF_GCP_ZONE_2 = "${length(var.gcp_zones) >= 2 ? element(var.gcp_zones,1) : ""}"
    TF_GCP_ZONE_3 = "${length(var.gcp_zones) == 3 ? element(var.gcp_zones,2) : ""}"
    TF_VM_TAGS    = "[${var.env_name}-internal,${var.env_name}-nat]"
    TF_NETWORK    = "${google_compute_network.bootstrap.name}"
    TF_SUBNETWORK = "${google_compute_subnetwork.bosh.name}"

    # Cloud-Config
    TF_CONCOURSE_SUBNET_RANGE         = "${google_compute_subnetwork.concourse.ip_cidr_range}"
    TF_CONCOURSE_SUBNET_GATEWAY       = "${google_compute_subnetwork.concourse.gateway_address}"
    TF_BOOTSTRAP_NETWORK_NAME         = "${google_compute_network.bootstrap.name}"
    TF_CONCOURSE_SUBNET_NAME          = "${google_compute_subnetwork.concourse.name}"
    TF_WEB_BACKEND_GROUP              = "${local.web_backend_service_name}"
    TF_CREDHUB_TARGET_POOL            = "${google_compute_target_pool.credhub_tp.name}"
    TF_CONCOURSE_NETWORK_STATIC_IPS   = "[${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,5)}-${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,8)}]"
    TF_CONCOURSE_NETWORK_RESERVED_IPS = "[${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,0)}-${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,4)}]"
    TF_CONCOURSE_NETWORK_VM_TAGS      = "[${var.env_name}-internal,${var.env_name}-nat]"

    TF_BOSH_SUBNET_RANGE         = "${google_compute_subnetwork.bosh.ip_cidr_range}"
    TF_BOSH_SUBNET_GATEWAY       = "${google_compute_subnetwork.bosh.gateway_address}"
    TF_BOSH_SUBNET_NAME          = "${google_compute_subnetwork.bosh.name}"
    TF_BOSH_NETWORK_STATIC_IPS   = "[${cidrhost(google_compute_subnetwork.bosh.ip_cidr_range,7)}-${cidrhost(google_compute_subnetwork.bosh.ip_cidr_range,10)}]"
    TF_BOSH_NETWORK_RESERVED_IPS = "[${cidrhost(google_compute_subnetwork.bosh.ip_cidr_range,0)}-${cidrhost(google_compute_subnetwork.bosh.ip_cidr_range,6)}]"
    TF_BOSH_NETWORK_VM_TAGS      = "[${var.env_name}-internal,${var.env_name}-nat]"

    #Credhub Deployment
    TF_CREDHUB_DNS_ENTRY = "${local.credhub_dns}"
    TF_UAA_DNS_ENTRY     = "${local.uaa_dns}"
    TF_UAA_URL           = "${local.uaa_url}"

    #Concourse Deployment
    TF_CONCOURSE_WEB_IP       = "${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,5)}"
    TF_CONCOURSE_EXTERNAL_URL = "${local.concourse_url}"
    TF_DOMAIN_NAME            = "${var.dns_domain_name}"
    TF_CREDHUB_URL            = "${local.credhub_url}"

    TF_METRICS_BACKEND_GROUP = "${local.metrics_backend_service_name}"

    TF_DB_STATIC_IP      = "${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,6)}"
    TF_METRICS_STATIC_IP = "${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,7)}"

    # IAAS
    TF_CA_CERT    = "${local.flags["gcp_https_lb"] == "true" ? tls_self_signed_cert.rootca_cert.cert_pem : ""}"
    TF_LB_PUB_KEY = "${local.flags["gcp_https_lb"] == "true" ? tls_private_key.ssl_private_key.public_key_pem : ""}"
  }
}

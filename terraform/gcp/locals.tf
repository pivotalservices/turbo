locals {
  "ssh_host"   = "${google_compute_address.jumpbox.address}"
  "jumpbox_id" = "${google_compute_instance.jumpbox.id}"
}

locals {
  stemcell  = "bosh-google-kvm-ubuntu-trusty-go_agent"
  iaas_type = "gcp"

  flags = {
    use_external_postgres = "false"
    ha_concourse          = "false"
    gcp_https_lb          = "true"
  }
}

locals {
  iaas_env = {
    TF_FLAGS = "${jsonencode(local.flags)}"

    # Bosh
    GCP_CREDENTIALS_JSON = "${var.gcp_key}"
    TF_SSH_USER          = "${var.ssh_user}"
    TF_ENV_NAME          = "${var.env_name}"
    TF_DIRECTOR_NAME     = "${var.env_name}-bosh1"
    TF_INTERNAL_CIDR     = "${google_compute_subnetwork.bosh.ip_cidr_range}"
    TF_INTERNAL_GW       = "${google_compute_subnetwork.bosh.gateway_address}"
    TF_INTERNAL_IP       = "${cidrhost(google_compute_subnetwork.bosh.ip_cidr_range, 6)}"
    TF_PROJECT_ID        = "${var.gcp_project_name}"
    TF_ZONE              = "${var.gcp_zone_1}"
    TF_VM_TAGS           = "[${var.env_name}-internal,${var.env_name}-nat]"
    TF_NETWORK           = "${google_compute_network.bootstrap.name}"
    TF_SUBNETWORK        = "${google_compute_subnetwork.bosh.name}"
    TF_CPI               = "${local.iaas_type}"
    TF_STEMCELL_TYPE     = "${local.stemcell}"

    # Cloud-Config
    TF_GCP_ZONE_1                     = "${var.gcp_zone_1}"
    TF_CONCOURSE_SUBNET_RANGE         = "${google_compute_subnetwork.concourse.ip_cidr_range}"
    TF_CONCOURSE_SUBNET_GATEWAY       = "${google_compute_subnetwork.concourse.gateway_address}"
    TF_BOOTSTRAP_NETWORK_NAME         = "${google_compute_network.bootstrap.name}"
    TF_CONCOURSE_SUBNET_NAME          = "${google_compute_subnetwork.concourse.name}"
    TF_CONCOURSE_WEB_BACKEND_GROUP    = "${google_compute_backend_service.concourse_web_lb_https_backend_service.name}"
    TF_CREDHUB_BACKEND_GROUP          = "${google_compute_backend_service.credhub_lb_https_backend_service.name}"
    TF_UAA_BACKEND_GROUP              = "${google_compute_backend_service.uaa_lb_https_backend_service.name}"
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
    TF_CREDHUB_DNS_ENTRY = "${replace(google_dns_record_set.credhub-lb.name,"/\\.$/","")}"
    TF_UAA_DNS_ENTRY     = "${replace(google_dns_record_set.uaa-lb.name,"/\\.$/","")}"

    #Concourse Deployment
    TF_CONCOURSE_WEB_IP       = "${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,5)}"
    TF_CONCOURSE_EXTERNAL_URL = "https://${replace(google_dns_record_set.concourse-lb.name,"/\\.$/","")}"
    TF_DOMAIN_NAME            = "${var.dns_domain_name}"
    TF_CREDHUB_URL            = "https://${replace(google_dns_record_set.credhub-lb.name,"/\\.$/","")}"

    TF_DB_STATIC_IP = "${cidrhost(google_compute_subnetwork.concourse.ip_cidr_range,6)}"

    # IAAS
    TF_CA_CERT    = "${local.flags["gcp_https_lb"] == "true" ? tls_self_signed_cert.rootca_cert.cert_pem : ""}"
    TF_LB_PUB_KEY = "${local.flags["gcp_https_lb"] == "true" ? tls_private_key.ssl_private_key.public_key_pem : ""}"
  }
}

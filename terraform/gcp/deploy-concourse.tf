#### BOSH deployment
resource "null_resource" "init_concourse" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/concourse/ops/",
    ]
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id = "${google_compute_instance.jumpbox.id}"
  }

  depends_on = [
    "google_compute_instance.jumpbox",
  ]
}

data "template_file" "cloud-config" {
  template = "${file("../../cloud-config/gcp/bosh-cloud-config.tpl.yml")}"

  vars {
    tf_env_name                    = "${var.env_name}"
    tf_concourse_subnet_range      = "${google_compute_subnetwork.concourse.ip_cidr_range}"
    tf_concourse_subnet_gateway    = "${google_compute_subnetwork.concourse.gateway_address}"
    tf_concourse_subnet_name       = "${google_compute_subnetwork.concourse.name}"
    tf_bootstrap_network_name      = "${google_compute_network.bootstrap.name}"
    tf_gcp_zone_1                  = "${var.gcp_zone_1}"
    tf_concourse_web_backend_group = "${google_compute_backend_service.concourse_web_lb_https_backend_service.name}"
    tf_credhub_backend_group       = "${google_compute_backend_service.credhub_lb_https_backend_service.name}"
    tf_uaa_backend_group           = "${google_compute_backend_service.uaa_lb_https_backend_service.name}"
  }
}

data "template_file" "concourse-deploy" {
  template = "${file("../../scripts/concourse-deploy.tpl.sh")}"

  vars {
    tf_ssh_user               = "${var.ssh_user}"
    tf_env_name               = "${var.env_name}"
    tf_concourse_subnet_range = "${google_compute_subnetwork.concourse.ip_cidr_range}"
    tf_concourse_dns_entry    = "${replace(google_dns_record_set.concourse-lb.name,"/\\.$/","")}"
    tf_flags                  = "${replace(jsonencode(var.flags), "\"", "\\\"")}"
    tf_domain_name            = "${var.dns_domain_name}"
  }
}

resource "null_resource" "concourse-dependencies" {
  provisioner "file" {
    content     = "${data.template_file.cloud-config.rendered}"
    destination = "/home/${var.ssh_user}/automation/cloud-config.yml"
  }

  provisioner "file" {
    content     = "${data.template_file.concourse-deploy.rendered}"
    destination = "/home/${var.ssh_user}/automation/concourse-deploy.sh"
  }

  provisioner "file" {
    source      = "../../ops/concourse/"
    destination = "/home/${var.ssh_user}/automation/concourse/ops"
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id     = "${google_compute_instance.jumpbox.id}"
    dependencies_1 = "${md5(data.template_file.cloud-config.rendered)}"
    dependencies_2 = "${md5(data.template_file.concourse-deploy.rendered)}"
    always         = "${uuid()}"
  }

  depends_on = [
    "null_resource.bosh-create-env",
    "null_resource.init_concourse",
  ]
}

resource "null_resource" "concourse-deploy" {
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/automation/concourse-deploy.sh",
      "/home/${var.ssh_user}/automation/concourse-deploy.sh",
    ]
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id     = "${google_compute_instance.jumpbox.id}"
    dependencies_1 = "${null_resource.concourse-dependencies.id}"
  }

  depends_on = [
    "null_resource.concourse-dependencies",
    "google_compute_backend_service.concourse_web_lb_https_backend_service",
  ]
}

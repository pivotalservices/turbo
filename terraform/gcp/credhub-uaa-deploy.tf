# #### BOSH deployment
# resource "null_resource" "init_credhub" {
#   provisioner "remote-exec" {
#     inline = [
#       "mkdir -p /home/${var.ssh_user}/automation/credhub/ops/",
#     ]
#   }

#   connection {
#     type        = "ssh"
#     host        = "${google_compute_address.jumpbox.address}"
#     user        = "${var.ssh_user}"
#     private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
#   }

#   triggers {
#     jumpbox_id = "${google_compute_instance.jumpbox.id}"
#   }

#   depends_on = [
#     "google_compute_instance.jumpbox",
#   ]
# }

# data "template_file" "credhub-deploy" {
#   template = "${file("../../scripts/credhub-uaa-deploy.tpl.sh")}"

#   vars {
#     tf_ssh_user = "${var.ssh_user}"
#     tf_env_name = "${var.env_name}"

#     #    tf_concourse_subnet_range = "${google_compute_subnetwork.concourse.ip_cidr_range}"
#     tf_credhub_dns_entry = "${replace(google_dns_record_set.credhub-lb.name,"/\\.$/","")}"
#     tf_uaa_dns_entry     = "${replace(google_dns_record_set.uaa-lb.name,"/\\.$/","")}"
#     tf_flags             = "${replace(jsonencode(var.flags), "\"", "\\\"")}"
#     tf_lb_ca             = "${tls_self_signed_cert.rootca_cert.cert_pem}"
#     tf_lb_public_key     = "${tls_private_key.ssl_private_key.public_key_pem}"

#     #    tf_domain_name            = "${var.dns_domain_name}"
#   }
# }

# resource "null_resource" "credhub-dependencies" {
#   provisioner "file" {
#     content     = "${data.template_file.credhub-deploy.rendered}"
#     destination = "/home/${var.ssh_user}/automation/credhub-uaa-deploy.sh"
#   }

#   provisioner "file" {
#     source      = "../../deployments/credhub/ops/"
#     destination = "/home/${var.ssh_user}/automation/credhub/ops"
#   }

#   connection {
#     type        = "ssh"
#     host        = "${google_compute_address.jumpbox.address}"
#     user        = "${var.ssh_user}"
#     private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
#   }

#   triggers {
#     jumpbox_id     = "${google_compute_instance.jumpbox.id}"
#     dependencies_1 = "${md5(data.template_file.cloud-config.rendered)}"
#     dependencies_2 = "${md5(data.template_file.credhub-deploy.rendered)}"
#     always         = "${uuid()}"
#   }

#   depends_on = [
#     "null_resource.bosh-create-env",
#     "null_resource.init_concourse",
#     "null_resource.concourse-deploy",
#   ]
# }

# resource "null_resource" "credhub-deploy" {
#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /home/${var.ssh_user}/automation/credhub-uaa-deploy.sh",
#       "/home/${var.ssh_user}/automation/credhub-uaa-deploy.sh",
#     ]
#   }

#   connection {
#     type        = "ssh"
#     host        = "${google_compute_address.jumpbox.address}"
#     user        = "${var.ssh_user}"
#     private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
#   }

#   triggers {
#     jumpbox_id     = "${google_compute_instance.jumpbox.id}"
#     dependencies_1 = "${null_resource.credhub-dependencies.id}"
#   }

#   depends_on = [
#     "null_resource.credhub-dependencies",
#     "google_compute_backend_service.credhub_lb_https_backend_service",
#     "google_compute_backend_service.uaa_lb_https_backend_service",
#   ]
# }

#### BOSH deployment
resource "template_dir" "credhub-uaa_generic_scripts" {
  source_dir      = "../../scripts/credhub-uaa/generic/"
  destination_dir = "${path.cwd}/local/automation/scripts/credhub-uaa/generic"

  vars {
    tf_ssh_user          = "${var.ssh_user}"
    tf_env_name          = "${var.env_name}"
    tf_credhub_dns_entry = "${replace(google_dns_record_set.credhub-lb.name,"/\\.$/","")}"
    tf_uaa_dns_entry     = "${replace(google_dns_record_set.uaa-lb.name,"/\\.$/","")}"
    tf_flags             = "${replace(jsonencode(var.flags), "\"", "\\\"")}"
    tf_lb_ca             = "${tls_self_signed_cert.rootca_cert.cert_pem}"
    tf_lb_public_key     = "${tls_private_key.ssl_private_key.public_key_pem}"
  }
}

resource "null_resource" "credhub-uaa_scripts" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/automation/credhub-uaa/ops",
      "mkdir -p /home/${var.ssh_user}/automation/scripts/credhub-uaa/generic",
    ]
  }

  provisioner "file" {
    source      = "${template_dir.credhub-uaa_generic_scripts.destination_dir}"
    destination = "/home/${var.ssh_user}/automation/scripts/credhub-uaa"
  }

  provisioner "file" {
    source      = "../../deployments/credhub-uaa/"
    destination = "/home/${var.ssh_user}/automation/credhub-uaa"
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.jumpbox.address}"
    user        = "${var.ssh_user}"
    private_key = "${tls_private_key.jumpbox_ssh_private_key.private_key_pem}"
  }

  triggers {
    jumpbox_id     = "${google_compute_instance.jumpbox.id}"
    dependencies_1 = "${null_resource.cloud-config-update.id}"
    dependencies_2 = "${template_dir.credhub-uaa_generic_scripts.id}"
    always         = "${uuid()}"
  }

  depends_on = [
    "null_resource.cloud-config-update",
  ]
}

resource "null_resource" "credhub-uaa-deploy" {
  provisioner "remote-exec" {
    inline = [
      "find /home/${var.ssh_user}/automation/scripts/ -name \\*.sh -exec chmod +x {} \\;",
      "/home/${var.ssh_user}/automation/scripts/credhub-uaa/generic/credhub-uaa-deploy.sh",
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
    dependencies_1 = "${null_resource.credhub-uaa_scripts.id}"
  }

  depends_on = [
    "null_resource.credhub-uaa_scripts",
    "google_compute_backend_service.credhub_lb_https_backend_service",
    "google_compute_backend_service.uaa_lb_https_backend_service",
  ]
}

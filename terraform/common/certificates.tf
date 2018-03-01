#### Root CA
resource "tls_private_key" "rootca_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "rootca_cert" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.rootca_private_key.private_key_pem}"

  validity_period_hours = 87600
  early_renewal_hours   = 8760

  is_ca_certificate = true

  allowed_uses = ["cert_signing"]

  subject {
    common_name         = "Test"
    organization        = "Test"
    organizational_unit = "Test"
    locality            = "Test"
    country             = "Test"
  }
}

#### Certificate
resource "tls_cert_request" "ssl_csr" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.ssl_private_key.private_key_pem}"

  dns_names = [
    "*.${var.dns_domain_name}",
  ]

  subject {
    common_name         = "${var.dns_domain_name}"
    organization        = "Test"
    organizational_unit = "Test"
    locality            = "Test"
    country             = "Test"
  }
}

resource "tls_locally_signed_cert" "ssl_cert" {
  cert_request_pem   = "${tls_cert_request.ssl_csr.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.rootca_private_key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.rootca_cert.cert_pem}"

  validity_period_hours = 87600 # 2 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "ssl_private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

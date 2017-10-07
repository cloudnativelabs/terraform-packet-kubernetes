# certificates and keys

resource "tls_private_key" "etcd-ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "etcd-ca" {
  key_algorithm   = "${tls_private_key.etcd-ca.algorithm}"
  private_key_pem = "${tls_private_key.etcd-ca.private_key_pem}"

  subject {
    common_name  = "etcd-ca"
    organization = "etcd"
  }

  is_ca_certificate     = true
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

# client certs are used for client (apiserver, locksmith, etcd-operator)
# to etcd communication
resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "client" {
  key_algorithm   = "${tls_private_key.client.algorithm}"
  private_key_pem = "${tls_private_key.client.private_key_pem}"

  subject {
    common_name  = "etcd-client"
    organization = "etcd"
  }

  ip_addresses = [
    "127.0.0.1",
    "${var.ip_addresses}",
  ]

  dns_names = ["${concat(
    var.client_advertise_fqdn,
    list(
      "localhost",
      "*.kube-etcd.kube-system.svc.cluster.local",
      "kube-etcd-client.kube-system.svc.cluster.local",
    ))}"]
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem = "${tls_cert_request.client.cert_request_pem}"

  ca_key_algorithm   = "${join(" ", tls_self_signed_cert.etcd-ca.*.key_algorithm)}"
  ca_private_key_pem = "${join(" ", tls_private_key.etcd-ca.*.private_key_pem)}"
  ca_cert_pem        = "${join(" ", tls_self_signed_cert.etcd-ca.*.cert_pem)}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "server" {
  key_algorithm   = "${tls_private_key.server.algorithm}"
  private_key_pem = "${tls_private_key.server.private_key_pem}"

  subject {
    common_name  = "etcd-server"
    organization = "etcd"
  }

  ip_addresses = [
    "127.0.0.1",
    "${var.ip_addresses}",
  ]

  dns_names = ["${concat(
    var.client_advertise_fqdn,
    list(
      "localhost",
      "*.kube-etcd.kube-system.svc.cluster.local",
      "kube-etcd-client.kube-system.svc.cluster.local",
    ))}"]
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem = "${tls_cert_request.server.cert_request_pem}"

  ca_key_algorithm   = "${join(" ", tls_self_signed_cert.etcd-ca.*.key_algorithm)}"
  ca_private_key_pem = "${join(" ", tls_private_key.etcd-ca.*.private_key_pem)}"
  ca_cert_pem        = "${join(" ", tls_self_signed_cert.etcd-ca.*.cert_pem)}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "peer" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "peer" {
  key_algorithm   = "${tls_private_key.peer.algorithm}"
  private_key_pem = "${tls_private_key.peer.private_key_pem}"

  subject {
    common_name  = "etcd-peer"
    organization = "etcd"
  }

  ip_addresses = [
    "${var.ip_addresses}",
  ]

  dns_names = ["${concat(
    var.peer_advertise_fqdn,
    list(
      "*.kube-etcd.kube-system.svc.cluster.local",
      "kube-etcd-client.kube-system.svc.cluster.local",
    ))}"]
}

resource "tls_locally_signed_cert" "peer" {
  cert_request_pem = "${tls_cert_request.peer.cert_request_pem}"

  ca_key_algorithm   = "${join(" ", tls_self_signed_cert.etcd-ca.*.key_algorithm)}"
  ca_private_key_pem = "${join(" ", tls_private_key.etcd-ca.*.private_key_pem)}"
  ca_cert_pem        = "${join(" ", tls_self_signed_cert.etcd-ca.*.cert_pem)}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

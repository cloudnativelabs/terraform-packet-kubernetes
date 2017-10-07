output "unit_etcd_member_dropin" {
  value = "${data.template_file.unit.rendered}"
}

output "client_url" {
  value = ""
}

# etcd TLS assets

output "ca_cert" {
  value = "${tls_self_signed_cert.etcd-ca.cert_pem}"
}

output "client_cert" {
  value = "${tls_locally_signed_cert.client.cert_pem}"
}

output "client_key" {
  value = "${tls_private_key.client.private_key_pem}"
}

output "server_cert" {
  value = "${tls_locally_signed_cert.server.cert_pem}"
}

output "server_key" {
  value = "${tls_private_key.server.private_key_pem}"
}

output "peer_cert" {
  value = "${tls_locally_signed_cert.peer.cert_pem}"
}

output "peer_key" {
  value = "${tls_private_key.peer.private_key_pem}"
}


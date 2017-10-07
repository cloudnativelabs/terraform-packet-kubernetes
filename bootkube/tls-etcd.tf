/* # etcd-client-ca.crt */
/* resource "local_file" "etcd_client_ca_crt" { */
/*   content  = "${tls_self_signed_cert.etcd-ca.cert_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd-client-ca.crt" */
/* } */
/*  */
/* # etcd-client.crt */
/* resource "local_file" "etcd_client_crt" { */
/*   content  = "${tls_locally_signed_cert.client.cert_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd-client.crt" */
/* } */
/*  */
/* # etcd-client.key */
/* resource "local_file" "etcd_client_key" { */
/*   content  = "${tls_private_key.client.private_key_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd-client.key" */
/* } */
/*  */
/* # server-ca.crt */
/* resource "local_file" "etcd_server_ca_crt" { */
/*   content  = "${tls_self_signed_cert.etcd-ca.cert_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd/server-ca.crt" */
/* } */
/*  */
/* # server.crt */
/* resource "local_file" "etcd_server_crt" { */
/*   content  = "${tls_locally_signed_cert.server.cert_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd/server.crt" */
/* } */
/*  */
/* # server.key */
/* resource "local_file" "etcd_server_key" { */
/*   content  = "${tls_private_key.server.private_key_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd/server.key" */
/* } */
/*  */
/* # peer-ca.crt */
/* resource "local_file" "etcd_peer_ca_crt" { */
/*   content  = "${tls_self_signed_cert.etcd-ca.cert_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd/peer-ca.crt" */
/* } */
/*  */
/* # peer.crt */
/* resource "local_file" "etcd_peer_crt" { */
/*   content  = "${tls_locally_signed_cert.peer.cert_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd/peer.crt" */
/* } */
/*  */
/* # peer.key */
/* resource "local_file" "etcd_peer_key" { */
/*   content  = "${tls_private_key.peer.private_key_pem}" */
/*   filename = "${var.asset_dir}/tls/etcd/peer.key" */
/* } */

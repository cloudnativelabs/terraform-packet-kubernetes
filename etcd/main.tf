data template_file "unit" {
  template = "${file("${path.module}/etcd.service")}"

  vars {
    unit_options          = "${join("\n", compact(var.unit_options))}"
    version               = "${var.version}"
    name                  = "${var.name}"
    client_advertise_fqdn = "${var.client_advertise_fqdn[0]}"
    peer_advertise_fqdn   = "${var.peer_advertise_fqdn[0]}"
    client_listen_host    = "${var.client_listen_host}"
    peer_listen_host      = "${var.peer_listen_host}"
    client_tls_dir        = "${var.client_tls_dir}"
    peer_tls_dir          = "${var.peer_tls_dir}"
    server_tls_dir        = "${var.server_tls_dir}"
    client_port           = "${var.client_port}"
    peer_port             = "${var.peer_port}"
  }
}

locals {
  client_url = "https://${var.client_advertise_fqdn[0]}:${var.client_port}"
}

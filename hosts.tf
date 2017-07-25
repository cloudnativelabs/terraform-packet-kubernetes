data "template_file" "hosts" {
  template = "${file("${path.module}/templates/hosts")}"

  vars {
    apiserver_ip       = "${packet_device.controller.0.ipv4_public}"
    apiserver_hostname = "${packet_device.controller.0.hostname}"
    apiserver_fqdn     = "${packet_device.controller.0.hostname}.${var.k8s_domain_name}"
    /* apiserver_entries  = "${formatlist(packet_device.controller_nodes.*.hostname)} */
  }
}

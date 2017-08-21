data "template_file" "hosts" {
  template   = "${file("${path.module}/templates/hosts")}"

  vars {
    node_hosts_entries = "${join("\n",
                        formatlist("%v %v %v",
                          concat(packet_device.controller.*.ipv4_public,
                                  packet_device.worker.*.ipv4_public),
                          concat(packet_device.controller.*.hostname,
                                  packet_device.worker.*.hostname),
                          formatlist("%v.%v",
                            concat(packet_device.controller.*.hostname,
                                    packet_device.worker.*.hostname),
                                    var.server_domain)))}"
  }
}

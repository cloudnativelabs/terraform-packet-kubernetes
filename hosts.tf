resource "null_resource" "controller" {
  count = "${var.controller_count}"

  triggers {
    hostname_prefix = "${format("controller-%02d", count.index + 1)}"
  }
}

resource "null_resource" "worker" {
  count = "${var.worker_count}"

  triggers {
    hostname_prefix = "${format("worker-%02d", count.index + 1)}"
  }
}

locals {
  public_ipv4 = "${concat(packet_device.controller.*.access_public_ipv4,
                          packet_device.worker.*.access_public_ipv4)}"

  controller_hostnames = "${formatlist("%v.%v",
                                        null_resource.controller.*.triggers.hostname_prefix,
                                        var.server_domain)}"

  worker_hostnames = "${formatlist("%v.%v",
                                    null_resource.worker.*.triggers.hostname_prefix,
                                    var.server_domain)}"

  hostnames = "${concat(local.controller_hostnames, local.worker_hostnames)}"

  hosts_entries = "${formatlist("%v %v %v",
                                local.public_ipv4,
                                concat(null_resource.controller.*.triggers.hostname_prefix,
                                       null_resource.worker.*.triggers.hostname_prefix),
                                local.hostnames)}"
}

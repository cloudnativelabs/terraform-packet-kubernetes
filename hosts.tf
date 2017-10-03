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

# Common
locals {
  controller_hostnames = "${formatlist("%v.%v",
                                        null_resource.controller.*.triggers.hostname_prefix,
                                        var.server_domain)}"

  worker_hostnames = "${formatlist("%v.%v",
                                    null_resource.worker.*.triggers.hostname_prefix,
                                    var.server_domain)}"

  hostnames = "${concat(local.controller_hostnames, local.worker_hostnames)}"

  public_ipv4 = "${concat(var.controller_ipv4_public,
                          var.worker_ipv4_public)}"

  # hosts_entries = "${formatlist("%v %v %v",
  #                               local.public_ipv4,
  #                               concat(null_resource.controller.*.triggers.hostname_prefix,
  #                                      null_resource.worker.*.triggers.hostname_prefix),
  #                               local.hostnames)}"

  controller_hosts_strings = "${length(var.controller_ipv4_public) != var.controller_count
    ? join(",", local.controller_hostnames)
    : join(",", var.controller_ipv4_public)}"

  worker_hosts_strings = "${length(var.worker_ipv4_public) != var.worker_count
    ? join(",", local.worker_hostnames)
    : join(",", var.worker_ipv4_public)}"

  controller_hosts = "${split(",", local.controller_hosts_strings)}"
  worker_hosts = "${split(",", local.worker_hosts_strings)}"

  hosts = "${concat(local.controller_hosts, local.worker_hosts)}"
}

data "template_file" "hosts_entries" {
  count    = "${var.controller_count + var.worker_count}"
  template = "$${hosts_entries}"

  vars {
    hosts_entries = "${format("%v %v",
                        lookup(module.all_networks.list[count.index * 3], "address"),
                        element(concat(packet_device.controller.*.hostname,
                                packet_device.worker.*.hostname), count.index))}"
  }
}

module "all_networks" {
  source = "./flatten"
  list   = "${concat(packet_device.controller.*.network[0], packet_device.worker.*.network[0])}"
}

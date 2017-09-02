resource "null_resource" "hosts" {
  count    = "${var.controller_count + var.worker_count}"
  triggers {
    entries = "${format("%v %v %v",
      element(concat(packet_device.controller.*.access_public_ipv4, packet_device.worker.*.access_public_ipv4), count.index),
      replace(
        element(concat(packet_device.controller.*.hostname,packet_device.worker.*.hostname), count.index),
        format("%v%v",".",var.server_domain), ""),
      element(concat(packet_device.controller.*.hostname,packet_device.worker.*.hostname), count.index))}"
  }
}

resource "null_resource" "net" {
  count = "${var.controller_count + var.worker_count}"

  triggers {
    public_ipv4 = "${element(concat(packet_device.controller.*.access_public_ipv4, packet_device.worker.*.access_public_ipv4), count.index)}"
  }
}

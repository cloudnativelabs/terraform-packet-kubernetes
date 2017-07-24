provider "packet" {
  auth_token = "${var.auth_token}"
}

resource "packet_device" "node" {
  depends_on = ["packet_ssh_key.ssh"]
  count      = "${var.controller_count + var.worker_count}"

  hostname         = "${format("%s-%02d", var.nodename, count.index + 1)}"
  plan             = "${var.server_type}"
  facility         = "${var.facility}"
  operating_system = "custom_ipxe"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
  user_data        = "${element(data.ct_config.node.*.rendered, count.index)}"
  ipxe_script_url  = "${var.ipxe_script_url}"
  always_pxe       = true
}

resource "packet_ssh_key" "ssh" {
  name       = "matchbox"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

data "ct_config" "node" {
  count        = "${var.controller_count + var.worker_count}"
  pretty_print = true
  content      = "${element(data.template_file.node.*.rendered, count.index)}"
}

data "template_file" "node" {
  count    = "${var.controller_count + var.worker_count}"
  template = "${file("${path.module}/templates/node.yaml")}"

  vars {
    nodename = "${format("%s-%02d", var.nodename, count.index + 1)}"
    node_label = "node-role.kubernetes.io/master"
  }
}

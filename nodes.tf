provider "packet" {
  auth_token = "${var.auth_token}"
}

resource "packet_device" "controller" {
  depends_on = ["packet_ssh_key.ssh"]
  count      = "${var.controller_count}"

  hostname         = "${format("controller-%02d", count.index + 1)}.${var.server_domain}"
  plan             = "${var.server_type}"
  facility         = "${var.facility}"
  operating_system = "custom_ipxe"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
  user_data        = "${data.ct_config.controller.*.rendered[count.index]}"
  ipxe_script_url  = "${var.ipxe_script_url}"
  always_pxe       = true
}

resource "packet_device" "worker" {
  depends_on = ["packet_ssh_key.ssh"]
  count      = "${var.worker_count}"

  hostname         = "${format("worker-%02d", count.index + 1)}.${var.server_domain}"
  plan             = "${var.server_type}"
  facility         = "${var.facility}"
  operating_system = "custom_ipxe"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
  user_data        = "${data.ct_config.worker.*.rendered[count.index]}"
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

data "ct_config" "controller" {
  count        = "${var.controller_count}"
  pretty_print = true
  content      = "${data.template_file.controller.*.rendered[count.index]}"
}

data "ct_config" "worker" {
  count        = "${var.worker_count}"
  pretty_print = true
  content      = "${data.template_file.worker.*.rendered[count.index]}"
}

data "template_file" "controller" {
  count    = "${var.controller_count}"
  template = "${file("${path.module}/templates/node.yaml")}"

  vars {
    node_name   = "${format("controller-%02d", count.index + 1)}"
    node_labels = "node-role.kubernetes.io/master"
  }
}

data "template_file" "worker" {
  count    = "${var.worker_count}"
  template = "${file("${path.module}/templates/node.yaml")}"

  vars {
    node_name   = "${format("worker-%02d", count.index + 1)}"
    node_labels = ""
  }
}

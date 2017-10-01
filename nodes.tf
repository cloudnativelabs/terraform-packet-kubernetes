provider "packet" {
  auth_token = "${var.auth_token}"
}

resource "packet_device" "controller" {
  depends_on = ["packet_ssh_key.ssh"]
  count      = "${var.controller_count}"

  hostname         = "${format("controller-%02d", count.index + 1)}.${var.server_domain}"
  plan             = "${var.server_type}"
  facility         = "${var.facility}"
  operating_system = "${var.operating_system}"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
  user_data        = "${data.ignition_config.controller.rendered}"
  ipxe_script_url  = "${var.ipxe_script_url}"
  always_pxe       = "${var.always_pxe}"
  spot_instance    = "${var.spot_instance}"
  spot_price_max   = "${var.spot_price_max}"
  termination_time = "${var.termination_time}"
}

resource "packet_device" "worker" {
  depends_on = ["packet_ssh_key.ssh"]
  count      = "${var.worker_count}"

  hostname         = "${format("worker-%02d", count.index + 1)}.${var.server_domain}"
  plan             = "${var.server_type}"
  facility         = "${var.facility}"
  operating_system = "${var.operating_system}"
  billing_cycle    = "hourly"
  project_id       = "${var.project_id}"
  user_data        = "${data.ignition_config.worker.rendered}"
  ipxe_script_url  = "${var.ipxe_script_url}"
  always_pxe       = "${var.always_pxe}"
  spot_instance    = "${var.spot_instance}"
  spot_price_max   = "${var.spot_price_max}"
  termination_time = "${var.termination_time}"
}

resource "packet_ssh_key" "ssh" {
  name       = "kube-metal.${var.server_domain}"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

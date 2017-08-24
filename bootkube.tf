module "bootkube" {
  source = "git://github.com/poseidon/bootkube-terraform.git?ref=v0.6.1"

  cluster_name = "${var.cluster_name}"

  #TODO: Dynamically determine apiservers from nodes, set to a variable
  api_servers                   = ["${packet_device.controller.0.hostname}"]
  asset_dir                     = "${var.asset_dir}"
  etcd_servers                  = ["${var.etcd_servers}"]
  experimental_self_hosted_etcd = "${var.experimental_self_hosted_etcd}"
}

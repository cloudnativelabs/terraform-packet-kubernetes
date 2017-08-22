module "bootkube" {
  source = "git://github.com/cloudnativelabs/bootkube-terraform.git?ref=kube-metal-v6"

  cluster_name = "${var.cluster_name}"

  #TODO: Dynamically determine apiservers from nodes, set to a variable
  api_servers                   = ["${packet_device.controller.0.hostname}.${var.server_domain}"]
  api_servers_ips               = ["${packet_device.controller.0.ipv4_public}"]
  asset_dir                     = "${var.asset_dir}"
  etcd_servers                  = ["${var.etcd_servers}"]
  experimental_self_hosted_etcd = "${var.experimental_self_hosted_etcd}"
}

module "bootkube" {
  source = "git://github.com/bzub/bootkube-terraform.git?ref=v0.5.1"

  cluster_name = "${var.cluster_name}"

  #TODO: Dynamically determine apiservers from nodes, set to a variable
  api_servers                   = ["${packet_device.controller.0.hostname}.${var.k8s_domain_name}"]
  asset_dir                     = "${var.asset_dir}"
  etcd_servers                  = ["${var.etcd_servers}"]
  experimental_self_hosted_etcd = "${var.experimental_self_hosted_etcd}"
}

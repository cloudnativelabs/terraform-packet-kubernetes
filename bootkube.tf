module "bootkube" {
  source                        = "github.com/cloudnativelabs/bootkube-terraform"
  cluster_name                  = "${var.cluster_name}"
  api_servers                   = "${packet_device.controller.*.hostname}"
  asset_dir                     = "${var.asset_dir}"
  networking                    = "${var.kube_router["pod_networking"] ? "kube-router" : "flannel"}"
  kube_router                   = "${var.kube_router}"
  etcd_servers                  = "${split(",", local.etcd_servers)}"
  experimental_self_hosted_etcd = "${var.experimental_self_hosted_etcd}"
  etcd_ca_cert                  = "${module.etcd.ca_cert}"
  etcd_client_cert              = "${module.etcd.client_cert}"
  etcd_client_key               = "${module.etcd.client_key}"
  etcd_server_cert              = "${module.etcd.server_cert}"
  etcd_server_key               = "${module.etcd.server_key}"
  etcd_peer_cert                = "${module.etcd.peer_cert}"
  etcd_peer_key                 = "${module.etcd.peer_key}"

  container_images = {
    hyperkube = "quay.io/coreos/hyperkube:v${local.kubernetes_v_patch}_coreos.0"
    etcd      = "quay.io/coreos/etcd:v3.1.8"
  }
}

locals {
  # TODO: Support etcd peers on all controllers. not just controller-01
  etcd_servers = "${
    length(var.etcd_servers) > 0 ? join(",", var.etcd_servers) : join(",",
      slice(local.controller_hostnames, 0, 1))
  }"
}

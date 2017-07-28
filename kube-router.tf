# Generate kube-router manifest.
data "template_file" "kube_router" {
  count    = "${var.use_kube_router}"
  template = "${file("${path.module}/templates/kube-router.yaml")}"

  vars {
    pod_networking = "${var.kube_router["pod_networking"]}"
    network_policy = "${var.kube_router["network_policy"]}"
    service_proxy  = "${var.kube_router["service_proxy"]}"
  }
}

# Install kube-router manifest if var.use_kube_router is true.
resource "local_file" "kube_router" {
  count      = "${var.use_kube_router}"
  depends_on = ["module.bootkube"]
  content    = "${data.template_file.kube_router.rendered}"
  filename   = "${path.module}/${var.asset_dir}/manifests/kube-router.yaml"
}

# Replace flannel if var.kube_router["pod_networking"] is enabled.
resource "local_file" "flannel_disable" {
  count      = "${var.use_kube_router * var.kube_router["pod_networking"]}"
  depends_on = ["module.bootkube"]
  content    = "# Pod networking provided by kube-router"
  filename   = "${path.module}/${var.asset_dir}/manifests/kube-flannel.yaml"
}

resource "local_file" "flannel_cfg_disable" {
  count      = "${var.use_kube_router * var.kube_router["pod_networking"]}"
  depends_on = ["module.bootkube"]
  content    = "# Pod networking provided by kube-router"
  filename   = "${path.module}/${var.asset_dir}/manifests/kube-flannel-cfg.yaml"
}

# Replace kube-proxy if var.kube_router["service_proxy"] is enabled.
resource "local_file" "kube_proxy_disable" {
  count      = "${var.use_kube_router * var.kube_router["service_proxy"]}"
  depends_on = ["module.bootkube"]
  content    = "# Service proxy provided by kube-router"
  filename   = "${path.module}/${var.asset_dir}/manifests/kube-proxy.yaml"
}

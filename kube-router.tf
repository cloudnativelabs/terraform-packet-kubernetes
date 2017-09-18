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
  filename   = "${path.module}/${var.asset_dir}/manifests-networking/kube-router.yaml"
}

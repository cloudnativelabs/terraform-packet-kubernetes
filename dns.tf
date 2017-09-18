data "template_file" "kube_dns_cfg" {
  template = "${file("${path.module}/templates/kube-dns-cfg.yaml")}"

  vars {
    server_domain = "${var.server_domain}"
  }
}

resource "local_file" "kube_dns_cfg" {
  depends_on = ["module.bootkube"]
  content    = "${data.template_file.kube_dns_cfg.rendered}"
  filename   = "${path.module}/${var.asset_dir}/manifests/kube-dns-cfg.yaml"
}

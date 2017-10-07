resource "template_dir" "kube-proxy-manifests" {
  count           = "${var.kube_router["service_proxy"] ? "0" : "1"}"
  source_dir      = "${path.module}/resources/kube-proxy"
  destination_dir = "${var.asset_dir}/manifests-networking"

  vars {
    hyperkube_image = "${var.container_images["hyperkube"]}"
    pod_cidr        = "${var.pod_cidr}"
  }
}

# Assets generated only when experimental self-hosted etcd is enabled
resource "template_dir" "flannel-manifests" {
  count           = "${var.networking == "flannel" ? 1 : 0}"
  source_dir      = "${path.module}/resources/flannel"
  destination_dir = "${var.asset_dir}/manifests-networking"

  vars {
    pod_cidr = "${var.pod_cidr}"
  }
}

resource "template_dir" "calico-manifests" {
  count           = "${var.networking == "calico" ? 1 : 0}"
  source_dir      = "${path.module}/resources/calico"
  destination_dir = "${var.asset_dir}/manifests-networking"

  vars {
    network_mtu = "${var.network_mtu}"
    pod_cidr    = "${var.pod_cidr}"
  }
}

# bootstrap-etcd.yaml pod bootstrap-manifest
resource "template_dir" "experimental-bootstrap-manifests" {
  count           = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/bootstrap-manifests"
  destination_dir = "${var.asset_dir}/experimental/bootstrap-manifests"

  vars {
    etcd_image                = "${var.container_images["etcd"]}"
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"
  }
}

# etcd subfolder - bootstrap-etcd-service.json and migrate-etcd-cluster.json TPR
resource "template_dir" "etcd-subfolder" {
  count           = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/etcd"
  destination_dir = "${var.asset_dir}/etcd"

  vars {
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"
  }
}

# etcd-operator deployment and etcd-service manifests
# etcd client, server, and peer tls secrets
resource "template_dir" "experimental-manifests" {
  count           = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/manifests"
  destination_dir = "${var.asset_dir}/experimental/manifests"

  vars {
    etcd_service_ip = "${cidrhost(var.service_cidr, 15)}"

    # Self-hosted etcd TLS certs / keys
    etcd_ca_cert     = "${base64encode(var.etcd_ca_cert)}"
    etcd_client_cert = "${base64encode(var.etcd_client_cert)}"
    etcd_client_key  = "${base64encode(var.etcd_client_key)}"
    etcd_server_cert = "${base64encode(var.etcd_server_cert)}"
    etcd_server_key  = "${base64encode(var.etcd_server_key)}"
    etcd_peer_cert   = "${base64encode(var.etcd_peer_cert)}"
    etcd_peer_key    = "${base64encode(var.etcd_peer_key)}"
  }
}

# Apply user manifests
resource "null_resource" "user_manifests" {
  depends_on = ["null_resource.bootkube_start"]

  # TODO: Download kubectl that corresponds to k8s version and host arch.
  provisioner "local-exec" {
    command = "sleep 20s && KUBECONFIG=assets/auth/kubeconfig kubectl --server=https://${packet_device.controller.0.ipv4_public} apply -f user-manifests"
  }
}

output "api_ip" {
  value = "${packet_device.controller.0.ipv4_public}"
}

output "kubeconfig_path" {
  value = "${path.module}/assets/auth/kubeconfig"
}

output "kube_version_minor" {
  value = "${null_resource.cluster_facts.triggers.kubernetes_v_minor}"
}

output "kube_version_patch" {
  value = "${null_resource.cluster_facts.triggers.kubernetes_v_patch}"
}

output "controller_hostnames" {
  value = "${packet_device.controller.*.hostname}"
}

output "controller_ips" {
  value = "${packet_device.controller.*.ipv4_public}"
}

output "worker_hostnames" {
  value = "${packet_device.worker.*.hostname}"
}

output "worker_ips" {
  value = "${packet_device.worker.*.ipv4_public}"
}

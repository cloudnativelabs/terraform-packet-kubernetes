output "api_ip" {
  value = "${local.public_ipv4[0]}"
}

output "api_hostname" {
  value = "${local.controller_hostnames[0]}"
}

output "node_public_ipv4" {
  value = "${join("\n",local.public_ipv4)}"
}

output "kubeconfig_path" {
  value = "${path.module}/${var.asset_dir}/auth/kubeconfig"
}

output "kube_version_minor" {
  value = "${local.kubernetes_v_minor}"
}

output "kube_version_patch" {
  value = "${local.kubernetes_v_patch}"
}

# output "hosts_file_entries" {
#   value = "${join("\n",local.hosts_entries)}"
# }

output "termination_timestamp" {
  value = "${local.termination_timestamps}"
}

output "termination_time_remaining" {
  value = "${local.termination_time_remainings}"
}

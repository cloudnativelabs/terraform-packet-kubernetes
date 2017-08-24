# vim: foldmethod=indent

## Provider
variable "auth_token" {
  description = "Secret key/password for your provider."
  type        = "string"
}

variable "project_id" {
  description = "Project ID"
  type        = "string"
}

## Machine
variable ipxe_script_url {
  description = "URL that points to an iPXE script to boot."
  type        = "string"
  default     = "https://raw.githubusercontent.com/cloudnativelabs/pxe/master/packet/coreos-alpha-packet.ipxe"
}

variable server_type {
  default = "baremetal_0"
}

variable facility {
  default = "ewr1"
}

variable controller_count {
  description = "How many kubernetes controller nodes you want."
  type        = "string"
}

variable worker_count {
  description = "How many kubernetes worker nodes you want."
  type        = "string"
}

variable server_domain {
  description = "Domain to append to server hostnames."
  type        = "string"
  default     = "localdomain"
}

## Bootkube
variable cluster_name {
  default = "test"
}

variable kubernetes_version {
  default = "v1.7"
}

variable asset_dir {
  default = "assets"
}

variable etcd_servers {
  type    = "list"
  default = []
}

variable experimental_self_hosted_etcd {
  default = true
}

## Customize Kubernetes components/addons
variable use_kube_router {
  default = true
}

variable kube_router {
  type = "map"
  default = {
    pod_networking = true
    service_proxy = true
    network_policy = true
  }
}

variable use_prometheus {
  default = true
}

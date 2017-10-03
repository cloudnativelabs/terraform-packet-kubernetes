variable controller_count {
  description = "How many kubernetes controller servers to create."
}

variable worker_count {
  description = "How many kubernetes worker servers to create."
}

variable server_domain {
  description = "Domain to append to server hostnames."
  type        = "string"
  default     = "localdomain"
}

variable "controller_ipv4_public" {
  description = ""
  type        = "list"
  default     = []
}

variable "worker_ipv4_public" {
  description = ""
  type        = "list"
  default     = []
}

## Bootkube
variable cluster_name {
  default = "test"
}

variable kubernetes_version {
  default = "v1.7.6"
}

variable asset_dir {
  default = "assets"
}

variable etcd_servers {
  type    = "list"
  default = []
}

variable experimental_self_hosted_etcd {
  default = false
}

## Customize Kubernetes components/addons
variable use_kube_router {
  default = true
}

variable kube_router {
  type = "map"

  default = {
    pod_networking = true
    service_proxy  = true
    network_policy = true
  }
}

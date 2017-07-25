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
  default     = "https://gitlab.com/cloudnativelabs/pxe/raw/master/packet/coreos-packet.ipxe"
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

## Bootkube
variable cluster_name {
  default = "test"
}

variable k8s_domain_name {
  default = "test.kube-router.io"
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

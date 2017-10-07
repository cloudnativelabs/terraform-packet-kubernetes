variable "unit_options" {
  description = ""
  default     = []
  type        = "list"
}

variable "version" {
  description = ""
  default     = "v3.2.7"
}

variable "write_files" {
  description = ""
  default     = false
}

variable "asset_dir" {
  description = ""
  default     = "assets"
}

variable "name" {
  description = ""
  default     = ""
}

variable "ip_addresses" {
  type = "list"

  default = [
    "127.0.0.1",
  ]
}

variable "client_advertise_fqdn" {
  description = ""
  type        = "list"
}

variable "peer_advertise_fqdn" {
  description = ""
  type        = "list"
}

variable "client_listen_host" {
  description = ""
  default     = "0.0.0.0"
}

variable "peer_listen_host" {
  description = ""
  default     = "0.0.0.0"
}

variable "client_tls_dir" {
  description = ""
  default     = "/etc/ssl/etcd"
}

variable "peer_tls_dir" {
  description = ""
  default     = "/etc/ssl/certs/etcd"
}

variable "server_tls_dir" {
  description = ""
  default     = "/etc/ssl/certs/etcd"
}

variable "client_port" {
  description = ""
  default     = 2379
}

variable "peer_port" {
  description = ""
  default     = 2380
}

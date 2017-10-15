module units {
  source = "../"

  systemd_unit_dir = "${path.module}/resources/systemd-units"
  networkd_unit_dir = "${path.module}/resources/networkd-units"

  systemd_units = [
    "kubelet.service",
    "var-lib-docker.mount",
  ]

  networkd_units = [
    "00-unmanaged.network",
  ]
}

data ignition_systemd_unit builtins_enabled{
  count = "${length(local.builtins_enabled_systemd_resources)}"

  name = "${local.builtins_enabled_systemd_resources[count.index]}"
  enabled = "true"
  content = "${
    file(
      format(
        "%v/%v",
        local.systemd_dir,
        local.builtins_enabled_systemd_resources[count.index]
      )
    )
  }"
}

# data ignition_systemd_unit kubelet {
#   name    = "kubelet.service"
#   enabled = "true"
#   content = "${file("${path.module}/userdata/systemd/${local.service_filenames[count.index]}")}"
# }

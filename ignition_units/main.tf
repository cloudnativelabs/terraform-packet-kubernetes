locals {
  all_units = "${
    concat(
      var.systemd_units,
      var.networkd_units,
    )
  }"

  systemd_units = "${
    matchkeys(
      local.all_units,
      null_resource.filenames.*.triggers.extensions,
      local.systemd_unit_extensions
    )
  }"

  networkd_units = "${
    matchkeys(
      local.all_units,
      null_resource.filenames.*.triggers.extensions,
      local.networkd_unit_extensions
    )
  }"

  systemd_unit_paths = "${
    formatlist(
      "%v/%v",
      var.systemd_unit_dir,
      local.systemd_units,
    )
  }"

  networkd_unit_paths = "${
    formatlist(
      "%v/%v",
      var.networkd_unit_dir,
      local.networkd_units,
    )
  }"

  systemd_unit_extensions = [
    "service",
    "socket",
    "device",
    "mount",
    "automount",
    "swap",
    "target",
    "path",
    "timer",
    "slice",
    "scope",
  ]

  networkd_unit_extensions = [
    "network",
    "netdev",
    "link",
  ]
}

resource null_resource filenames {
  count = "${length(local.all_units)}"

  triggers {
    extensions = "${
      element(
        split(".", local.all_units[count.index]),
        length(split(".", local.all_units[count.index])) - 1,
      )
    }"
  }
}

data ignition_systemd_unit out {
  count = "${length(var.systemd_units)}"

  name = "${local.systemd_units[count.index]}"
  enabled = true
  content = "${
    file(local.systemd_unit_paths[count.index])
  }"
}

data ignition_networkd_unit out {
  count = "${length(var.networkd_units)}"

  name = "${local.networkd_units[count.index]}"
  content = "${
    file(local.networkd_unit_paths[count.index])
  }"
}

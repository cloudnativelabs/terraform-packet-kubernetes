locals {
  builtins_keys = [
    "use_resolved_stub_dns",
    "install_kubelet",
  ]

  builtins_values = "${
    list(
      local.use_resolved_stub_dns,
      local.install_kubelet
    )
  }"

  use_resolved_stub_dns = [
    "link_${data.ignition_link.mask_no_dns_listener.id}",
    "link_${data.ignition_link.use_resolved_stub_listener.id}",
  ]

  install_kubelet = "${
    list(
      "systemd_resource_kubelet.service"
    )
  }"

  resource_dir = "${path.module}/resources"
  systemd_dir = "${local.resource_dir}/systemd-units"

  builtins_enabled_links = "${
    compact(
      null_resource.builtins_enabled.*.triggers.links
    )
  }"

  builtins_enabled_systemd = "${
    data.ignition_systemd_unit.builtins_enabled.*.id
  }"

  builtins_enabled_systemd_resources = "${
    compact(
      null_resource.builtins_enabled.*.triggers.systemd_resources
    )
  }"

  builtins_enabled = "${
    flatten(
      matchkeys(
        local.builtins_values,
        local.builtins_keys,
        var.builtins
      )
    )
  }"
}

resource null_resource builtins_enabled {
  count = "${length(local.builtins_enabled)}"

  triggers {
    links = "${
      replace(
        local.builtins_enabled[count.index],
        "/^link_.*/",
        "is_link"
      ) == "is_link"
        ? replace(
            local.builtins_enabled[count.index],
            "/^link_(.*)/",
            "$1"
          )
        : ""
    }"

    systemd_resources = "${
      replace(
        local.builtins_enabled[count.index],
        "/^systemd_resource_.*/",
        "is_systemd_resource"
      ) == "is_systemd_resource"
        ? replace(
            local.builtins_enabled[count.index],
            "/^systemd_resource_(.*)/",
            "$1"
          )
        : ""
    }"
  }
}

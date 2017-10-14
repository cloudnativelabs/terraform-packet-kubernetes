locals {
  use_resolved_stub_dns = [
    "link_${data.ignition_link.mask_no_dns_listener.id}",
    "link_${data.ignition_link.use_resolved_stub_listener.id}",
  ]

  builtins_keys = [
    "use_resolved_stub_dns"
  ]

  builtins_values = "${
    list(
      local.use_resolved_stub_dns
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
      compact(
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
      )
    }"
  }
}

data ignition_link mask_no_dns_listener {
  filesystem = "root"
  path = "/etc/systemd/resolved.conf.d/50-no-dns-listener.conf"
  target = "/dev/null"
}

data ignition_link use_resolved_stub_listener {
  filesystem = "root"
  path = "/etc/resolv.conf"
  target = "/usr/lib/systemd/resolv.conf"
}

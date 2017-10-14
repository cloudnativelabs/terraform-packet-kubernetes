data ignition_config main {
  links = ["${local.builtins_enabled_links}"]
  systemd = ["${local.builtins_enabled_systemd}"]
}

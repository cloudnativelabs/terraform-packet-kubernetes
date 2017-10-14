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

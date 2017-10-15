output systemd_unit_ids {
  value = "${data.ignition_systemd_unit.out.*.id}"
}

output networkd_unit_ids {
  value = "${data.ignition_networkd_unit.out.*.id}"
}

output unit_paths {
  value = "${
    concat(
      local.systemd_unit_paths,
      local.networkd_unit_paths,
    )
  }"
}

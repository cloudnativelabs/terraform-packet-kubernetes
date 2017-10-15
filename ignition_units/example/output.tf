output systemd_unit_ids {
  value = "${module.units.systemd_unit_ids}"
}

output networkd_unit_ids {
  value = "${module.units.networkd_unit_ids}"
}

output unit_paths {
  value = "${module.units.unit_paths}"
}


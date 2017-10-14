data ignition_config main {
  links = ["${compact(null_resource.builtins_enabled.*.triggers.links)}"]
}

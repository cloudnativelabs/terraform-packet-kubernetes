module "etcd" {
  source = "github.com/cloudnativelabs/terraform-ignition-etcd-member"

  unit_options          = ["${format("ConditionHost=%s*",
    null_resource.controller.*.triggers.hostname_prefix[0])}"]
  client_advertise_fqdn = ["local.controller_hostnames[0]"]
  peer_advertise_fqdn   = ["local.controller_hostnames[0]"]
  name                  = "local.controller_hostnames[0]"
  write_files           = true
  asset_dir             = "${var.asset_dir}"
}

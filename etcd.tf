module "etcd" {
  source = "github.com/cloudnativelabs/terraform-ignition-etcd-member"

  unit_options          = ["ConditionHost=controller-01*"]
  client_advertise_fqdn = ["controller-01.${var.server_domain}"]
  peer_advertise_fqdn   = ["controller-01.${var.server_domain}"]
  name                  = "controller-01.${var.server_domain}"
  write_files           = true
  asset_dir             = "${var.asset_dir}"
}

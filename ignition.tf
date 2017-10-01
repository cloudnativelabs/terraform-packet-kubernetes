data "ignition_config" "controller" {
  count       = "${var.controller_count}"
  networkd    = [ "${data.ignition_networkd_unit.unmanaged.id}" ]
  filesystems = [ "${data.ignition_filesystem.data.id}" ]

  systemd = [
    "${concat(
      data.ignition_systemd_unit.services.*.id,
      data.ignition_systemd_unit.mounts.*.id,
      data.ignition_systemd_unit.automounts.*.id,
      list(
        data.ignition_systemd_unit.mask_locksmithd.id,
        data.ignition_systemd_unit.kubelet_image.id
      ),
    )}",
    "${data.ignition_systemd_unit.kubelet_controller.id}",
    "${data.ignition_systemd_unit.etcd.id}",
  ]

  files = [
    "${list(
      data.ignition_file.sysctl_max_user_watches.id,
      data.ignition_file.symlink_persistent_dirs.id,
      data.ignition_file.bootkube_start.id,
      data.ignition_file.systemd_timesyncd_conf.id
    )}",
    "${data.ignition_file.controller_etc_hostname.*.id[count.index]}",
  ]
}

data "ignition_config" "worker" {
  count       = "${var.worker_count}"
  networkd    = ["${data.ignition_networkd_unit.unmanaged.id}"]
  filesystems = ["${data.ignition_filesystem.data.id}"]

  systemd = [
    "${concat(
      data.ignition_systemd_unit.services.*.id,
      data.ignition_systemd_unit.mounts.*.id,
      data.ignition_systemd_unit.automounts.*.id,
      list(
        data.ignition_systemd_unit.mask_locksmithd.id,
        data.ignition_systemd_unit.kubelet_image.id
      ),
    )}",
  ]

  files = [
    "${list(
      data.ignition_file.sysctl_max_user_watches.id,
      data.ignition_file.symlink_persistent_dirs.id,
      data.ignition_file.bootkube_start.id,
      data.ignition_file.systemd_timesyncd_conf.id
    )}",
    "${data.ignition_file.worker_etc_hostname.*.id[count.index]}",
  ]
}

locals {
  service_filenames = [
    "resolved-setup.service",
    "kubelet.path",
    "kubelet.service",
    "bootkube.service",
    "btrfs-create-subvolumes.service",
  ]

  mount_names = [
    "DATA",
    "var-lib-docker",
    "var-lib-rkt",
    "var-lib-kubelet",
    "var-etcd",
    "etc-kubernetes",
    "etc-ssl-etcd",
    "home-core",
  ]

  mount_filenames     = "${formatlist("%s.mount", local.mount_names)}"
  automount_filenames = "${formatlist("%s.automount", local.mount_names)}"
}

data ignition_networkd_unit "unmanaged" {
  name    = "00-unmanaged.network"
  content = "${file("${path.module}/userdata/networkd/00-unmanaged.network")}"
}

data ignition_systemd_unit "kubelet_image" {
  name = "kubelet.service"

  dropin = [{
    "name" = "00-kubelet-image.conf"

    "content" = <<EOF
[Service]
Environment="KUBELET_IMAGE_URL=quay.io/coreos/hyperkube"
Environment="KUBELET_IMAGE_TAG=v${local.kubernetes_v_patch}_coreos.0"
EOF
  }]
}

data ignition_systemd_unit "kubelet_controller" {
  name = "kubelet.service"

  dropin = [{
    "name"    = "50-kubelet-controller.conf"
    "content" = <<EOF
[Service]
Environment=NODE_LABELS=node-role.kubernetes.io/master
EOF
  }]
}

data ignition_systemd_unit "etcd" {
  name    = "etcd-member.service"
  enabled = "true"

  dropin = [{
    "name"    = "40-etcd-cluster.conf"
    "content" = "${module.etcd.unit_etcd_member_dropin}"
  }]
}

data ignition_systemd_unit "mask_locksmithd" {
  name = "locksmithd.service"
  mask = true
}

data ignition_systemd_unit "services" {
  count = "${length(local.service_filenames)}"

  name    = "${local.service_filenames[count.index]}"
  enabled = "true"
  content = "${file("${path.module}/userdata/systemd/${local.service_filenames[count.index]}")}"
}

data ignition_systemd_unit "mounts" {
  count = "${length(local.mount_names)}"

  name    = "${local.mount_filenames[count.index]}"
  enabled = "true"
  content = "${file("${path.module}/userdata/systemd/${local.mount_filenames[count.index]}")}"
}

data ignition_systemd_unit "automounts" {
  count = "${length(local.mount_names)}"

  name    = "${local.automount_filenames[count.index]}"
  enabled = "true"
  content = "${file("${path.module}/userdata/systemd/${local.automount_filenames[count.index]}")}"
}

data "ignition_filesystem" "data" {
  name = "data"

  mount {
    device          = "/dev/sda"
    format          = "btrfs"
    wipe_filesystem = false
    label           = "DATA"
    options         = ["-L", "DATA"]
  }
}

data "ignition_file" "controller_etc_hostname" {
  count      = "${var.controller_count}"
  filesystem = "root"
  path       = "/etc/hostname"
  mode       = "0644"

  content {
    content = "${format("controller-%02d.%s", count.index + 1, var.server_domain)}"
  }
}

data "ignition_file" "worker_etc_hostname" {
  count      = "${var.worker_count}"
  filesystem = "root"
  path       = "/etc/hostname"
  mode       = "0644"

  content {
    content = "${format("worker-%02d.%s", count.index + 1, var.server_domain)}"
  }
}

data "ignition_file" "sysctl_max_user_watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/max-user-watches.conf"
  content    {
    content = "fs.inotify.max_user_watches=16184"
  }
}

data "ignition_file" "symlink_persistent_dirs" {
  filesystem = "root"
  path       = "/opt/bootkube/symlink-persistent-dirs.sh"
  mode       = "0544"
  content    {
    content = "${file("${path.module}/userdata/files/symlink-persistent-dirs.sh")}"
  }
}

data "ignition_file" "bootkube_start" {
  filesystem = "root"
  path       = "/opt/bootkube/bootkube-start"
  mode       = "0544"
  uid        = "500"
  gid        = "500"
  content    {
    content = "${file("${path.module}/userdata/files/bootkube-start.sh")}"
  }
}

data "ignition_file" "systemd_timesyncd_conf" {
  filesystem = "root"
  path       = "/etc/systemd/timesyncd.conf"
  mode       = "0620"
  content    {
    content = "${file("${path.module}/userdata/files/timesyncd.conf")}"
  }
}

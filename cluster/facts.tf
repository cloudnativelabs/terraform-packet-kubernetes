locals {
  kubernetes_v_minor = "${chomp(replace(var.kubernetes_version,"/^.*v?(\\d\\.\\d)\\.\\d/","$1"))}"
  kubernetes_v_patch = "${chomp(replace(var.kubernetes_version,"/^.*v?(\\d\\.\\d\\.\\d)/","$1"))}"
}

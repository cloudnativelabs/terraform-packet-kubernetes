resource "null_resource" "kubernetes_facts" {
  triggers {
    kubernetes_v_minor = "${replace(data.http.kubernetes-version.body,"/^.*v?(\\d\\.\\d)\\.\\d/","$1")}"
    kubernetes_v_patch = "${replace(data.http.kubernetes-version.body,"/^.*v?(\\d\\.\\d\\.\\d)/","$1")}"
  }
}

data "http" "kubernetes-version" {
  url = "https://storage.googleapis.com/kubernetes-release/release/stable-${replace(var.kubernetes_version,"/^v?(\\d\\.\\d).*$/","$1")}.txt"
}

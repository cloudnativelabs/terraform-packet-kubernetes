# Write private SSH key to file for e2e, etc
resource "local_file" "ssh_key_private" {
  content  = "${tls_private_key.ssh.private_key_pem}"
  filename = "${path.module}/assets/auth-custom/id_rsa"

  provisioner "local-exec" {
    command = "chmod 600 ${path.module}/assets/auth-custom/id_rsa"
  }
}

# Secure copy etcd TLS assets and kubeconfig to all nodes.
resource "null_resource" "copy_secrets" {
  count = "${var.controller_count + var.worker_count}"

  connection {
    type = "ssh"
    host = "${element(local.public_ipv4, count.index)}"

    user        = "core"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /etc/hosts /etc/hosts-backup-$(date --utc --iso-8601=seconds)",
      "echo '${join("\n",local.hosts_entries)}' | sudo tee -a /etc/hosts",
    ]
  }

  provisioner "file" {
    content     = "${module.bootkube.kubeconfig}"
    destination = "$HOME/kubeconfig"
  }

  provisioner "file" {
    content     = "${module.etcd.ca_cert}"
    destination = "$HOME/etcd-client-ca.crt"
  }

  provisioner "file" {
    content     = "${module.etcd.client_cert}"
    destination = "$HOME/etcd-client.crt"
  }

  provisioner "file" {
    content     = "${module.etcd.client_key}"
    destination = "$HOME/etcd-client.key"
  }

  provisioner "file" {
    content     = "${module.etcd.server_cert}"
    destination = "$HOME/etcd-server.crt"
  }

  provisioner "file" {
    content     = "${module.etcd.server_key}"
    destination = "$HOME/etcd-server.key"
  }

  provisioner "file" {
    content     = "${module.etcd.peer_cert}"
    destination = "$HOME/etcd-peer.crt"
  }

  provisioner "file" {
    content     = "${module.etcd.peer_key}"
    destination = "$HOME/etcd-peer.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/ssl/etcd/etcd",
      "sudo mkdir -p /etc/kubernetes",
      "echo nameserver 127.0.0.53 | sudo tee -a /etc/kubernetes/resolv.conf",
      "echo search ${var.server_domain} | sudo tee -a /etc/kubernetes/resolv.conf",
      "sudo mv etcd-client* /etc/ssl/etcd/",
      "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /etc/ssl/etcd/etcd/server-ca.crt",
      "sudo mv etcd-server.crt /etc/ssl/etcd/etcd/server.crt",
      "sudo mv etcd-server.key /etc/ssl/etcd/etcd/server.key",
      "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /etc/ssl/etcd/etcd/peer-ca.crt",
      "sudo mv etcd-peer.crt /etc/ssl/etcd/etcd/peer.crt",
      "sudo mv etcd-peer.key /etc/ssl/etcd/etcd/peer.key",
      "sudo chown -R etcd:etcd /etc/ssl/etcd",
      "sudo chmod -R 500 /etc/ssl/etcd",
    ]
  }
}

# Secure copy bootkube assets to ONE controller and start bootkube to perform
# one-time self-hosted cluster bootstrapping.
resource "null_resource" "bootkube_start" {
  # Without depends_on, this remote-exec may start before the kubeconfig copy.
  # Terraform only does one task at a time, so it would try to bootstrap
  # Kubernetes and Tectonic while no Kubelets are running. Ensure all nodes
  # receive a kubeconfig before proceeding with bootkube and tectonic.
  depends_on = ["null_resource.copy_secrets", "local_file.kube_router"]

  connection {
    type        = "ssh"
    host        = "${element(local.public_ipv4, 0)}"
    user        = "core"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    timeout     = "20m"
  }

  provisioner "file" {
    source      = "${var.asset_dir}"
    destination = "$HOME/assets"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo systemctl start kubelet.service",
      "sudo systemctl restart kubelet.path",
      "sleep 15",
      /* "sudo rm -rf /home/core/assets/tls/etcd", */
      /* "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /home/core/assets/tls/etcd/etcd-client-ca.crt", */
      /* "sudo chown coreos:coreos/home/core/assets/tls/etcd/etcd-client-ca.crt", */
      /* "sudo cp /etc/ssl/etcd/etcd-client.crt /home/core/assets/tls/etcd/etcd-client.crt", */
      /* "sudo chown coreos:coreos/home/core/assets/tls/etcd/etcd-client.crt", */
      /* "sudo cp /etc/ssl/etcd/etcd-client.key /home/core/assets/tls/etcd/etcd-client.key", */
      /* "sudo chown coreos:coreos/home/core/assets/tls/etcd/etcd-client.key", */
      /* "sudo cp -r /etc/ssl/etcd/etcd /home/core/assets/tls/etcd", */
      /* "sudo chown -R coreos:coreos/home/core/assets/tls/etcd", */
      "sudo mv /home/core/assets /opt/bootkube",
      "sudo systemctl start bootkube",
    ]
  }

  # Delay a bit to let things settle.
  # Brought on by scripts that use this TF module and failed when
  # trying to create resources immediately after startup.
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

# Start kubelet on the rest of the controllers.
resource "null_resource" "cluster_start_controller" {
  count      = "${var.controller_count - 1}"
  depends_on = ["null_resource.bootkube_start"]

  connection {
    type        = "ssh"
    host        = "${element(local.public_ipv4, count.index + 1)}"
    user        = "core"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo systemctl start kubelet.service",
      "sudo systemctl restart kubelet.path",
    ]
  }
}

# Start kubelet on the workers.
resource "null_resource" "cluster_start_worker" {
  count      = "${var.worker_count}"
  depends_on = ["null_resource.bootkube_start"]

  connection {
    type        = "ssh"
    host        = "${element(local.public_ipv4, count.index + length(var.controller_count))}"
    user        = "core"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
      "sudo systemctl start kubelet.service",
      "sudo systemctl restart kubelet.path",
    ]
  }
}

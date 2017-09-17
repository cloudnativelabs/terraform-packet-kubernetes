# kube-metal

[![Join the chat at https://gitter.im/cloudnativelabs/kube-metal](https://badges.gitter.im/cloudnativelabs/kube-metal.svg)](https://gitter.im/cloudnativelabs/kube-metal?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

kube-metal is a [Terraform](https://www.terraform.io/) module that automates the creation of Kubernetes
clusters and the infrastructure they run on.

Using Terraform you can quickly spin up Kubernetes clusters for CI and testing
purposes, or for permanent use. kube-metal is designed to support testing core
Kubernetes components such as
[kube-router](https://github.com/cloudnativelabs/kube-router).

## Quickstart
kube-metal is highly configurable, but you can try it out in a few short steps.

Get kube-metal:
```sh
git clone https://github.com/cloudnativelabs/kube-metal.git
cd kube-metal
```

Use the [get-providers.sh](/tools/get-providers.sh) script to download and configure Terraform providers:
```sh
tools/get-providers.sh
```

Make sure you have a `~/.terraformrc` that uses the new provider binaries. You
can run the following:
```sh
cat <<EOF > ~/.terraformrc
providers {                                          
  ct = "${GOPATH}/bin/terraform-provider-ct"         
  packet = "${GOPATH}/bin/terraform-provider-packet" 
}
EOF
```

Provision the cluster on Packet.net. Be sure to have an account and API key created first.
```sh
terraform init
terraform apply
```

Update your hosts file for DNS resolution of the API controller
```sh
./tools/etc-hosts.sh
```

Enjoy!
```sh
./tools/kubectl.sh get nodes
./tools/kubectl.sh get pods --all-namespaces -o wide
```

This is perfect for scripting clusters for CI or demos. Read the
[getting started docs](#getting-started) for more detailed provisioning steps.

## How It Works

Terraform is used to provision and configure kubernetes nodes, and also generate
TLS secrets for etcd/Kubernetes. Kubernetes apiserver and etcd are exposed on a
public address by default so that CI systems and you can interact with them.
These services are configured with TLS authentication/authorization to prevent
unwanted access.

[Bootkube](https://github.com/kubernetes-incubator/bootkube)
is used to bootstrap the Kubernetes core components and start
a self-hosted cluster.

Etcd is run self-hosted within the Kubernetes cluster by default, but
this is easily configured to use an etcd server outside of Kubernetes.

## Getting Started
These are detailed instructions to expand on the [quickstart
instructions](#quickstart).

### Prerequisites

kube-metal uses a few unreleased features from Terraform providers. You can get
them automatically with the provided [get-providers.sh](/tools/get-providers.sh)
script.

```sh
tools/get-providers.sh
```

Then create a file `~/terraformrc` and add the following:
```
providers {                                          
  ct = "${GOPATH}/bin/terraform-provider-ct"         
  packet = "${GOPATH}/bin/terraform-provider-packet" 
}
```

### Configuration

There are many configuration options described in [variables.tf](/variables.tf).
If you copy [terraform.tfvars-example](/terraform.tfvars-example) to a new file
called `terraform.tfvars` then you can make your configuration changes
persistent and Terraform will use them for all commands.

You will need to run `terraform init` before proceeding which downloads
Terraform modules, and sets up the file backend store (`terraform.tfstate`).

### Running kube-metal

Running `terraform plan` will show you what will be created.
Running `terraform apply` will actually create the resources. In brief,
it will:
- Create an SSH key for itself and your CI system that will allow shell
  access to the nodes.
- Boot your new nodes which get configured from a Container Linux Config
  that is converted to Ignition json and given to the provider as user-data.
  This config is available to view at [templates/node.yaml](/templates/node.yaml)
  in this repo.
- Generated all assets and secrets needed for Bootkube, and copies them
  to the nodes as needed.
- Starts a kubelet service on all nodes, and Bootkube on one node to begin
  the cluster bootstrapping process.

### Accessing The Cluster

#### /etc/hosts DNS Setup
Due to the TLS security mechanisms in place, you must access a kube-metal
provisioned cluster via the DNS name that was given to the controller node.

A script is provided that will add/replace the hosts file entry for you.
```sh
$ ./etc-hosts.sh
147.75.77.43 controller-01.test.kube-router.io
INFO: Removing above host file entry.
INFO: Appending the following host entry to your hosts file.
147.75.77.43 controller-01.test.kube-router.io
```

Alternatively you can use the host entries in the terraform output to manually
update your hosts file or DNS server.
```sh
# Get the hosts file entries and append them to /etc/hosts
terraform output hosts_file_entries | sudo tee -a /etc/hosts
```

To see all available output variables run `terraform output`.

#### kubectl.sh
We've included a convenient [kubectl.sh](/kubectl.sh) wrapper that runs kubectl
with all the options needed to access your cluster baked right in.
```sh
./kubectl.sh get pods --all-namespaces
```

The kubeconfig is available under `assets/auth/kubeconfig` for use with the
usual kubectl command.
```sh
# Backup a previous kubeconfig
mv ~/.kube/config ~/.kube/config-$(date --utc --iso-8601=seconds)

# Go into the kube-metal directory
cd kube-metal

# Option 1
ln -s "${PWD}/assets/auth/kubeconfig" ~/.kube/config
kubectl get nodes

# Option 2
KUBECONFIG="${PWD}/assets/auth/kubeconfig" kubectl get nodes
```

## Cleaning Up

Run `terraform destroy`


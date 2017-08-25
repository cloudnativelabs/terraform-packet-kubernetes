# kube-metal

kube-metal is a [Terraform](https://www.terraform.io/) module that automates the
creation of Kubernetes clusters on [Packet](https://www.packet.net/) servers.

Using Terraform you can quickly spin up Kubernetes clusters for CI and testing
purposes, or for permanent use. kube-metal is designed to support testing core
Kubernetes components such as
[kube-router](https://github.com/cloudnativelabs/kube-router).

## Quickstart
kube-metal is highly configurable, but you can get going right away by running:
```
go get github.com/coreos/terraform-provider-ct
echo 'providers { ct = "${GOPATH}/bin/terraform-provider-ct" }' \
  >> ~/terraformrc
terraform init
terraform apply
```

You will be asked to provide a few fields like an API key, project ID, etc, then
you're off! Follow the [cluster access section](#accessing-the-cluster) to use
your new cluster.

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

terraform-provider-ct is not yet included in the official providers, so you have
to download that manually.

```sh
# Here's how to install the prequisites:
go get github.com/coreos/terraform-provider-ct
```

Then create a file `~/terraformrc` and add the following:
```
providers {
  ct = "${GOPATH}/bin/terraform-provider-ct"
}
```

### Configuration

When you run `terraform plan` you will be asked for an API key for your
hosting provider (if needed), and the number of nodes you want. There are
more configuration options described in [variables.tf](/variables.tf). If you copy
[terraform.tfvars-example](/terraform.tfvars-example) to a new file called
`terraform.tfvars` then you can make your configuration changes persistent and
Terraform will use them for all commands.

You will need to run `terraform init` to download the Terraform modules
before proceeding.

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
Luckily you will find host entries in the terraform output that you can copy and
paste into your /etc/hosts file.

For example:
```sh
# Get the hosts file entries and append them to /etc/hosts
terraform output hosts_file_entries | sudo tee -a /etc/hosts
```

#### kubectl.sh
We've included a convenient [kubectl.sh](/kubectl.sh) wrapper that runs kubectl
with all the options needed to access your cluster baked right in.
```
./kubectl.sh get pods --all-namespaces
```

## Cleaning Up

Run `terraform destroy`


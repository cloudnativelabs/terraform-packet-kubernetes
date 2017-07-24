# Koalesce

Koalesce aims to be an end-to-end test-suite for Kubernetes software.
We plan to implement a `go test` type tool for interacting with a
temporary cluster.

Using [Terraform](https://www.terraform.io/) you can quickly spin up Kubernetes
clusters for CI and testing purposes.  Koalesce is designed to support testing
core Kubernetes components such as kube-router. It also focuses on bare-metal
clusters, although the provider should be easily swapped out.

Koalesce currently only supports provisioning on [packet.net](https://www.packet.net)
servers, although we plan to support other cloud providers and Vagrant very
soon.

## How It Works

Terraform is used to provision and configure kubernetes nodes, and also
generate TLS secrets for etcd/Kubernetes. Kubernetes apiserver and etcd
are exposed on a public address by default so that CI systems and you
can interact with them. Although Koalesce services are only intented to
be operational for a short time, still these services are configured with TLS
authentication/authorization to prevent unwanted access.

[Bootkube](https://github.com/kubernetes-incubator/bootkube)
is used to bootstrap the Kubernetes core components and start
a self-hosted cluster.

Etcd is run self-hosted within the Kubernetes cluster by default, but
this is easily configured to use an etcd server outside of Kubernetes.

## Getting Started

### Prerequisites

We had to extend the capabilities of the packethost/packngo Go library
as well as the terraform-provider-packet plugin to support Koalesce. So
until those changes are accepted upstream there are a few Terraform plugins
that must be compiled on your system before using Koalesce.

Here's how to install the prequisites:
- `go get github.com/bzub/terraform-provider-packet`
- `go get github.com/coreos/terraform-provider-ct`

Then create a file `~/terraformrc` and add the following:
```
providers {
  packet = "${GOPATH}/bin/terraform-provider-packet"
  ct = "${GOPATH}/bin/terraform-provider-ct"
}
```

### Configuration

When you run `terraform apply` you will be asked for an API key for your
hosting provider (if needed), and the number of nodes you want. There are
more configuration options described in [variables.tf](/variables.tf). If you copy
[terraform.tfvars-example](/terraform.tfvars-example) to a new file called
`terraform.tfvars` then you can make your configuration changes persistent and
Terraform will use them for all commands.

You will need to run `terraform init` to download the Terraform modules
before proceeding.

### Running Koalesce

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

## Cleaning Up

Run `terraform destroy`


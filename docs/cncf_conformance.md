# CNCF Conformance

## Prerequisites

The following prerequisites apply to follow these instructions. You will need:

* A Linux or MacOS machine with
  [Terraform 0.11.x](https://www.terraform.io/downloads.html) installed.
* A [Google Cloud](gcp.md), or [AWS](aws.md) account with enough permissions to provide the needed
  infrastructure

## Preparation

**NOTE:** These instructions are targeted at a
[Google Cloud Platform](gcp.md) deployment. To deploy in [AWS](aws.md),
please run `make aws` instead of
`make gcp` in the step below, and edit the resulting file accordingly.

**NOTE:** To install `dcos-kubernetes` in an existing cluster, please follow
[these instructions](existing_cluster.md).

First, clone this repository:

```shell
$ git clone git@github.com:mesosphere/dcos-kubernetes-quickstart.git
$ cd dcos-kubernetes-quickstart
```

Then generate the default infrastructure configuration:

```shell
$ make gcp
```

This will output sane defaults to `.deploy/terraform.tfvars`. Now, edit
said file and set the `gcp_project` and the `ssh_public_key_file` variables.
Please, do not set a smaller instance (VM) type on the risk of failing to
install Kubernetes. In the end, the `.deploy/terraform.tfvars` file
should look something like this:

```
cluster_name = "dcos-kubernetes"
cluster_name_random_string = true

dcos_version = "1.12.3"

num_of_masters = "1"
num_of_private_agents = "4"
num_of_public_agents = "1"

bootstrap_instance_type = "n1-standard-1"
master_instance_type = "n1-standard-8"
private_agent_instance_type = "n1-standard-8"
public_agent_instance_type = "n1-standard-8"

# admin_ips = "0.0.0.0/0" # uncomment to access master from any IP

gcp_project = "YOUR_GCP_PROJECT"
gcp_region = "us-central1"
ssh_public_key_file = "/PATH/YOUR_GCP_SSH_PUBLIC_KEY.pub"
#
# If you want to use GCP service account key instead of GCP SDK
# uncomment the line below and update it with the path to the key file
# gcp_credentials = "/PATH/YOUR_GCP_SERVICE_ACCOUNT_KEY.json"
#
```

Now, launch the DC/OS cluster by running:

```shell
$ KUBERNETES_VERSION=1.14.1 make get-cli launch-dcos setup-cli
```

This command will:

1. Download the `dcos` CLI and `kubectl` to your machine.
1. Provision the necessary infrastructure in GCP and install DC/OS.
1. Setup the `dcos` CLI to access the newly created DC/OS cluster.

As part of the last step, your browser will open and ask you to login with
a Google, GitHub or Microsoft account. Choose an option and copy the resulting
OpenID token to the shell where you ran the above mentioned command.

## Installing Mesosphere Kubernetes Engine

To install Mesosphere Kuberentes Engine and create a Kubernetes cluster in the newly created DC/OS cluster run:

```shell
$ KUBERNETES_FRAMEWORK_VERSION=2.3.0-1.14.1 \
  PATH_TO_PACKAGE_OPTIONS=./resources/options-ha.json make install
```

Wait until all tasks are running before proceeding.
You can track installation progress as follows:

```shell
$ make watch-kubernetes-cluster
```

When installation is successful you will see the following output:

```
Using Kubernetes cluster: dev/kubernetes01
deploy (serial strategy) (COMPLETE)
   etcd (serial strategy) (COMPLETE)
      etcd-0:[peer] (COMPLETE)
      etcd-1:[peer] (COMPLETE)
      etcd-2:[peer] (COMPLETE)
   control-plane (dependency strategy) (COMPLETE)
      kube-control-plane-0:[instance] (COMPLETE)
      kube-control-plane-1:[instance] (COMPLETE)
      kube-control-plane-2:[instance] (COMPLETE)
   mandatory-addons (serial strategy) (COMPLETE)
      mandatory-addons-0:[instance] (COMPLETE)
   node (dependency strategy) (COMPLETE)
      kube-node-0:[kubelet] (COMPLETE)
      kube-node-1:[kubelet] (COMPLETE)
      kube-node-2:[kubelet] (COMPLETE)
   public-node (dependency strategy) (COMPLETE)
```

When all tasks are in state `COMPLETE`, press `Ctrl-C` to terminate the `watch`
process and proceed to access your Kubernetes cluster.

## Accessing the Kubernetes API

In order to access the Kubernetes API from outside the DC/OS cluster, we must
first be able to access it. This can be achieved by running the following
command:

```shell
$ make marathon-lb kubeconfig
```

This command will expose the Kubernetes API for our newly created Kubernetes cluster, and configure `kubectl` to access said Kubernetes cluster.
Let's try and list this cluster's nodes:

```shell
$ ./kubectl --context devkubernetes01 get nodes
NAME                                                  STATUS   ROLES    AGE     VERSION
kube-control-plane-0-instance.devkubernetes01.mesos   Ready    master   5m18s   v1.14.1
kube-control-plane-1-instance.devkubernetes01.mesos   Ready    master   5m12s   v1.14.1
kube-control-plane-2-instance.devkubernetes01.mesos   Ready    master   5m11s   v1.14.1
kube-node-0-kubelet.devkubernetes01.mesos             Ready    <none>   2m58s   v1.14.1
kube-node-1-kubelet.devkubernetes01.mesos             Ready    <none>   2m42s   v1.14.1
kube-node-2-kubelet.devkubernetes01.mesos             Ready    <none>   2m39s   v1.14.1
```

If the output is similar to what is shown above, you're good to go and run the
conformance test suite.

## Running the test suite

To run the test suite and grab the results, follow the
[official instructions](https://github.com/cncf/k8s-conformance/blob/master/instructions.md).

## Destroy the infrastructure

In order to delete the DC/OS cluster created above, run:

```shell
$ make destroy
```

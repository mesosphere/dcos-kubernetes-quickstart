# CNCF Conformance

## Prerequisites

The following prerequisites apply to follow these instructions. You will need:

* A Linux or MacOS machine with
  [Terraform 0.11.x](https://www.terraform.io/downloads.html) installed.
* A [Google Cloud](gcp.md), [AWS](aws.md) or [Azure](azure.md)
  account with enough permissions to provide the needed infrastructure

## Preparation

**NOTE:** These instructions are targeted at a
[Google Cloud Platform](gcp.md) deployment. To deploy in [AWS](aws.md)
or [Azure](azure.md), please run `make aws` or `make azure` instead of
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

This will output sane defaults to `.deploy/desired_cluster_profile`. Now, edit
said file and set the `gcp_project` and the `gce_ssh_pub_key_file` variables.
Please, do not set a smaller instance (VM) type on the risk of failing to
install Kubernetes. In the end, the `.deploy/desired_cluster_profile` file
should look something like this:

```
custom_dcos_download_path = "https://downloads.dcos.io/dcos/stable/1.11.2/dcos_generate_config.sh"
num_of_masters = "1"
num_of_private_agents = "3"
num_of_public_agents = "1"
#
gcp_project = "<project-id>"
gcp_region = "us-west1"
gcp_ssh_pub_key_file = "<path-to-ssh-public-key>"
#
# If you want to use GCP service account key instead of GCP SDK
# uncomment the line below and update it with the path to the key file
#gcp_credentials_key_file = "/PATH/YOUR_GCP_SERVICE_ACCOUNT_KEY.json"
#
gcp_bootstrap_instance_type = "n1-standard-1"
gcp_master_instance_type = "n1-standard-8"
gcp_agent_instance_type = "n1-standard-8"
gcp_public_agent_instance_type = "n1-standard-8"
#
# Change public/private subnetworks e.g. "10.65." if you want to run multiple clusters in the same project
gcp_compute_subnetwork_public = "10.64.0.0/22"
gcp_compute_subnetwork_private = "10.64.4.0/22"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"

# Uncomment the line below if you want short living cheap cluster for testing
#gcp_scheduling_preemptible = "true"
```

Now, launch the DC/OS cluster by running:

```shell
$ KUBERNETES_VERSION=1.10.4 make get-cli launch-dcos setup-cli
```

This command will:

1. Download the `dcos` CLI and `kubectl` to your machine.
1. Provision the necessary infrastructure in GCP and install DC/OS.
1. Setup the `dcos` CLI to access the newly created DC/OS cluster.

As part of the last step, your browser will open and ask you to login with
a Google, GitHub or Microsoft account. Choose an option and copy the resulting
OpenID token to the shell where you ran the above mentioned command.

## Installing `dcos-kubernetes`

To install `dcos-kubernetes` in the newly created DC/OS cluster run:

```shell
$ KUBERNETES_FRAMEWORK_VERSION=1.1.1-1.10.4 \
  PATH_TO_PACKAGE_OPTIONS=./resources/options-ha.json make install
```

Wait until all tasks are running before proceeding.
You can track installation progress as follows:

```shell
$ watch ./dcos kubernetes plan show deploy
```

When installation is successful you will see the following output:

```
deploy (serial strategy) (COMPLETE)
   etcd (serial strategy) (COMPLETE)
      etcd-0:[peer] (COMPLETE)
      etcd-1:[peer] (COMPLETE)
      etcd-2:[peer] (COMPLETE)
   apiserver (parallel strategy) (COMPLETE)
      kube-apiserver-0:[instance] (COMPLETE)
      kube-apiserver-1:[instance] (COMPLETE)
      kube-apiserver-2:[instance] (COMPLETE)
   mandatory-addons (serial strategy) (COMPLETE)
      mandatory-addons-0:[additional-cluster-role-bindings] (COMPLETE)
      mandatory-addons-0:[kube-dns] (COMPLETE)
      mandatory-addons-0:[metrics-server] (COMPLETE)
      mandatory-addons-0:[dashboard] (COMPLETE)
      mandatory-addons-0:[ark] (COMPLETE)
   kubernetes-api-proxy (parallel strategy) (COMPLETE)
      kubernetes-api-proxy-0:[install] (COMPLETE)
   controller-manager (parallel strategy) (COMPLETE)
      kube-controller-manager-0:[instance] (COMPLETE)
      kube-controller-manager-1:[instance] (COMPLETE)
      kube-controller-manager-2:[instance] (COMPLETE)
   scheduler (parallel strategy) (COMPLETE)
      kube-scheduler-0:[instance] (COMPLETE)
      kube-scheduler-1:[instance] (COMPLETE)
      kube-scheduler-2:[instance] (COMPLETE)
   node (parallel strategy) (COMPLETE)
      kube-node-0:[kube-proxy, coredns, kubelet] (COMPLETE)
      kube-node-1:[kube-proxy, coredns, kubelet] (COMPLETE)
      kube-node-2:[kube-proxy, coredns, kubelet] (COMPLETE)
   public-node (parallel strategy) (COMPLETE)
      kube-node-public-0:[kube-proxy, coredns, kubelet] (COMPLETE)
```

When all tasks are in state `COMPLETE`, press `Ctrl-C` to terminate the `watch`
process and proceed to access your Kubernetes cluster.

## Accessing the Kubernetes API

In order to access the Kubernetes API from outside the DC/OS cluster, we must
first be able to access it. This can be achieved by running the following
command:

```shell
$ make kubeconfig
```

This command will configure `kubectl` to access our DC/OS Kubernetes cluster.
Let's try and list this cluster's nodes:

```shell
$ ./kubectl get nodes
NAME                                          STATUS    ROLES     AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos          Ready     <none>    5m        v1.10.4
kube-node-1-kubelet.kubernetes.mesos          Ready     <none>    5m        v1.10.4
kube-node-2-kubelet.kubernetes.mesos          Ready     <none>    5m        v1.10.4
kube-node-public-0-kubelet.kubernetes.mesos   Ready     <none>    4m        v1.10.4
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

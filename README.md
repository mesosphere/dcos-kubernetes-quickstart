# Kubernetes on DC/OS

Kubernetes is now available as a DC/OS package to quickly, and reliably run Kubernetes clusters on Mesosphere DC/OS.

![](docs/assets/ui-install.gif)

**NOTE:** The latest `dcos-kubernetes-quickstart` doesn't support any Kubernetes framework version before
`1.2.0-1.10.5` due the changes how the Kubernetes API is exposed.

## Known limitations

Before proceeding, please check the [current package limitations](https://docs.mesosphere.com/service-docs/kubernetes/1.2.2-1.10.7/limitations/).

## Pre-Requisites

First, make sure your cluster fulfils the [Kubernetes package default requirements](https://docs.mesosphere.com/service-docs/kubernetes/1.2.2-1.10.7/install/#prerequisites/).

Then, check the requirements for running this quickstart:

* Linux or MacOS
* [Terraform 0.11.x](https://www.terraform.io/downloads.html). On MacOS, you can install with [brew](https://brew.sh/):
  ```bash
  $ brew install terraform
  ```
* [Google Cloud](docs/gcp.md), [AWS](docs/aws.md) or [Azure](docs/azure.md)
  account with enough permissions to provide the needed infrastructure

## Quickstart

Once the pre-requisites are met, clone this repo:

```bash
$ git clone git@github.com:mesosphere/dcos-kubernetes-quickstart.git && cd dcos-kubernetes-quickstart
```

### Prepare infrastructure configuration

**This quickstart defaults to Google Cloud**

First, make sure you have have followed the [Google Cloud setup instructions](docs/gcp.md).

Then, start by generating the default infrastructure configuration:

```bash
$ make gcp
```

This will output sane defaults to `.deploy/desired_cluster_profile`.
Now, edit said file and set your `project-id` and the `gce_ssh_pub_key_file`
(the SSH public key you will use to log-in into your new VMs later).

**WARNING:** Please, do not set a smaller instance (VM) type on the risk of failing to
install Kubernetes.

```
custom_dcos_download_path = "https://downloads.dcos.io/dcos/stable/1.11.5/dcos_generate_config.sh"
num_of_masters = "1"
num_of_private_agents = "3"
num_of_public_agents = "1"
#
gcp_project = "YOUR_GCP_PROJECT"
gcp_region = "us-central1"
gce_ssh_pub_key_file = "/PATH/YOUR_GCP_SSH_PUBLIC_KEY.pub"
#
gcp_bootstrap_instance_type = "n1-standard-1"
gcp_master_instance_type = "n1-standard-8"
gcp_agent_instance_type = "n1-standard-8"
gcp_public_agent_instance_type = "n1-standard-8"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"
```

For more advanced scenarios, please check the [terraform-dcos documentation for Google Cloud](https://github.com/dcos/terraform-dcos/tree/master/gcp).

### Kubernetes configuration

#### RBAC

**NOTE:** This `quickstart` will provision a Kubernetes cluster without `RBAC` support.

To deploy a cluster with enabled [RBAC](https://docs.mesosphere.com/services/kubernetes/1.2.2-1.10.7/authn-and-authz/#rbac) update `.deploy/options.json`:

```
{
  "kubernetes": {
    "authorization_mode": "RBAC",
    "public_node_count": 1
  }
}
```

If you want to give users access to the Kubernetes API check [documentation](https://docs.mesosphere.com/services/kubernetes/1.2.2-1.10.7/authn-and-authz/#giving-users-access-to-the-kubernetes-api).

**NOTE:** The authorization mode for a cluster must be chosen when installing the package. Changing the authorization mode after installing the package is not supported.

#### HA Cluster

**NOTE:** By default, it will provision a Kubernetes cluster with one (1) worker node, and
a single instance of every control plane component.

To deploy a **highly-available** cluster with three (3) private and one (1) public workers node update `.deploy/options.json`:

```
{
  "kubernetes": {
    "high_availability": true,
    "node_count": 3,
    "public_node_count": 1
  }
}
```

### Download command-line tools

If you haven't already, please download DC/OS client, `dcos` and Kubernetes
client, `kubectl`:

```bash
$ make get-cli
```

The `dcos` and `kubectl` binaries will be downloaded to the current workdir.
It's up to you to decided whether or not to copy or move them to another path,
e.g. a path included in `PATH`.

### Install

You are now ready to provision the DC/OS cluster and install the Kubernetes package:

```bash
$ make deploy
```

Terraform will now try and provision the infrastructure on your chosen cloud
provider, and then proceed to install DC/OS.

When DC/OS is up and running, the Kubernetes package installation will take place.

Wait until all tasks are running before trying to access the Kubernetes API.

You can watch the progress what was deployed so far with:

```bash
$ watch ./dcos kubernetes plan show deploy
```

Below is an example of how it looks like when the install ran successfully:

```
deploy (serial strategy) (COMPLETE)
   etcd (serial strategy) (COMPLETE)
      etcd-0:[peer] (COMPLETE)
   apiserver (dependency strategy) (COMPLETE)
      kube-apiserver-0:[instance] (COMPLETE)
   mandatory-addons (serial strategy) (COMPLETE)
      mandatory-addons-0:[additional-cluster-role-bindings] (COMPLETE)
      mandatory-addons-0:[kubelet-tls-bootstrapping] (COMPLETE)
      mandatory-addons-0:[kube-dns] (COMPLETE)
      mandatory-addons-0:[metrics-server] (COMPLETE)
      mandatory-addons-0:[dashboard] (COMPLETE)
      mandatory-addons-0:[ark] (COMPLETE)
   kubernetes-api-proxy (dependency strategy) (COMPLETE)
      kubernetes-api-proxy-0:[install] (COMPLETE)
   controller-manager (dependency strategy) (COMPLETE)
      kube-controller-manager-0:[instance] (COMPLETE)
   scheduler (dependency strategy) (COMPLETE)
      kube-scheduler-0:[instance] (COMPLETE)
   node (dependency strategy) (COMPLETE)
      kube-node-0:[kube-proxy, coredns, kubelet] (COMPLETE)
   public-node (dependency strategy) (COMPLETE)
      kube-node-public-0:[kube-proxy, coredns, kubelet] (COMPLETE)
```

You can access DC/OS Dashboard and check Kubernetes package tasks under Services:

```bash
$ make ui
```

### Exposing the Kubernetes API

Check the [exposing Kubernetes API doc](docs/exposing_kubernetes_api.md) to understand how
the Kubernetes API gets exposed.

**NOTE:** If you have changed in `.deploy/desired_cluster_profile` file the number of
`num_of_public_agents` to more than `1`, please scale `marathon-lb` service to the same number,
so you can access Kubernetes API from any DC/OS public agent.

### Accessing the Kubernetes API

In order to access the Kubernetes API from outside the DC/OS cluster, one needs
to configure `kubectl`, the Kubernetes CLI tool:

```bash
$ make kubeconfig
```

Let's test accessing the Kubernetes API and list the Kubernetes cluster nodes:

```bash
$ ./kubectl get nodes
NAME                                          STATUS    ROLES     AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos          Ready     <none>    3m        v1.10.7
kube-node-public-0-kubelet.kubernetes.mesos   Ready     <none>    2m        v1.10.7
```

And now, let's check how the system Kubernetes pods are doing:

```bash
$ ./kubectl -n kube-system get pods
NAME                                    READY     STATUS    RESTARTS   AGE
kube-dns-797d4bd8dd-g4cd7               3/3       Running   0          10m
kubernetes-dashboard-5c469b58b8-wxss9   1/1       Running   0          10m
metrics-server-77c969f8c-ssbf8          1/1       Running   0          10m
```

### Accessing the Kubernetes Dashboard

You will be able to access the Kubernetes Dashboard by running:

```bash
$ kubectl proxy
```

Then pointing your browser at:

```
http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/
```

## Uninstall Kubernetes

To uninstall the DC/OS Kubernetes package while leaving your DC/OS cluster up,
run:

```bash
$ make uninstall
```

**NOTE:** This will only uninstall Kubernetes. Make sure you destroy your DC/OS
cluster using the instructions below when you finish testing, or otherwise you
will need to delete all cloud resources manually!

## Destroy cluster

To destroy the whole deployment:

```bash
$ make destroy
```

Last, clean generated resources:
```bash
$ make clean
```

## Documentation

For more details, please see the [docs folder](docs) and as well check the official [service docs](https://docs.mesosphere.com/service-docs/kubernetes/1.2.2-1.10.7)

## Community
Get help and connect with other users on the [mailing list](https://groups.google.com/a/dcos.io/forum/#!forum/kubernetes) or on DC/OS community [Slack](http://chat.dcos.io/) in the #kubernetes channel.

## Roadmap for Kubernetes on DC/OS

* [ ] Automatic, and secure exposure of the Kubernetes API
* [ ] Allow multiple Kubernetes nodes per DC/OS agent
* [ ] Manage multiple Kubernetes clusters
* [ ] DC/OS as the cloud provider - fully integrated with DC/OS authentication, storage (CSI), and load-balancing (Service and Ingress)
* [ ] Node Pools - each pool has its own configuration, including placement constraints, taints and tolerations, etc.
* [ ] Support network policies
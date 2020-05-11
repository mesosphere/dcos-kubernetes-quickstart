# Kubernetes on DC/OS

Kubernetes is now available as a DC/OS package to quickly, and reliably run Kubernetes clusters on Mesosphere DC/OS.

![](docs/assets/ui-install.gif)

**NOTE:** The latest `dcos-kubernetes-quickstart` doesn't support any Kubernetes framework version before `2.0.0-1.12.1`. The reason is that now creating Kubernetes clusters requires the installation of the [Mesosphere Kubernetes Engine](https://docs.mesosphere.com/services/kubernetes/2.5.0-1.16.9/overview/#cluster-manager).

## Known limitations

Before proceeding, please check the [current package limitations](https://docs.mesosphere.com/service-docs/kubernetes/2.5.0-1.16.9/limitations/).

## Pre-Requisites

Check the requirements for running this quickstart:

* Linux or MacOS
* [Terraform 0.11.x](https://www.terraform.io/downloads.html). On MacOS, you can install with [brew](https://brew.sh/):
  ```bash
  $ brew install terraform
  ```
* [Google Cloud](docs/gcp.md) or [AWS](docs/aws.md) account with enough permissions to provide the
  needed infrastructure

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

This will output sane defaults to `.deploy/terraform.tfvars`.
Now, edit said file and set your `gcp_project` and the `ssh_public_key_file`
(the SSH public key you will use to log-in into your new VMs later).

**WARNING:** Please, do not set a smaller instance (VM) type on the risk of failing to
install Kubernetes.

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

**NOTE:** The current release of the DC/OS GCP Terraform module also requires the `GOOGLE_PROJECT`
and `GOOGLE_REGION` environment variables to be set. Please set them with appropriates values for
your deployment:

```
$ export GOOGLE_PROJECT="YOUR_GCP_PROJECT"
$ export GOOGLE_REGION="us-central1"
```

### Kubernetes configuration

#### RBAC

**NOTE:** This `quickstart` will provision a Kubernetes cluster with `RBAC` support.

To deploy a cluster with RBAC disabled [RBAC](https://docs.mesosphere.com/services/kubernetes/2.5.0-1.16.9/operations/authn-and-authz/#rbac) update `.deploy/options.json`:

```
{
  "service": {
    "name": "dev/kubernetes01"
  },
  "kubernetes": {
    "authorization_mode": "AlwaysAllow"
  }
}
```

If you want to give users access to the Kubernetes API check [documentation](https://docs.mesosphere.com/services/kubernetes/2.5.0-1.16.9/operations/authn-and-authz/#giving-users-access-to-the-kubernetes-api).

**NOTE:** The authorization mode for a cluster must be chosen when installing the package. Changing the authorization mode after installing the package is not supported.

#### HA Cluster

**NOTE:** By default, it will provision a Kubernetes cluster with one (1) worker node, and
a single instance of every control plane component.

To deploy a **highly-available** cluster with three (3) private Kubernetes nodes update `.deploy/options.json`:

```
{
  "service": {
    "name": "dev/kubernetes01"
  },
  "kubernetes": {
    "high_availability": true,
    "private_node_count": 3
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
$ make watch-kubernetes-cluster
```

Below is an example of how it looks like when the install ran successfully:

```
Using Kubernetes cluster: dev/kubernetes01
deploy (serial strategy) (COMPLETE)
   etcd (serial strategy) (COMPLETE)
      etcd-0:[peer] (COMPLETE)
   control-plane (dependency strategy) (COMPLETE)
      kube-control-plane-0:[instance] (COMPLETE)
   mandatory-addons (serial strategy) (COMPLETE)
      mandatory-addons-0:[instance] (COMPLETE)
   node (dependency strategy) (COMPLETE)
      kube-node-0:[kubelet] (COMPLETE)
   public-node (dependency strategy) (COMPLETE)
```

You can access DC/OS Dashboard and check Kubernetes package tasks under Services:

```bash
$ make ui
```

### Exposing the Kubernetes API

Check the [exposing Kubernetes API doc](docs/exposing_kubernetes_api.md) to understand how
the Kubernetes API gets exposed.
To actually expose the Kubernetes API for the new Kubernetes cluster using Marathon-LB, run:

```bash
$ make marathon-lb
```

**NOTE:** If you have changed in `.deploy/terraform.tfvars` file the number of
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
$ ./kubectl --context devkubernetes01 get nodes
NAME                                                  STATUS   ROLES    AGE     VERSION
kube-control-plane-0-instance.devkubernetes01.mesos   Ready    master   5m18s   v1.16.9
kube-node-0-kubelet.devkubernetes01.mesos             Ready    <none>   2m58s   v1.16.9
```

And now, let's check how the system Kubernetes pods are doing:

```bash
$ ./kubectl --context devkubernetes01 -n kube-system get pods
NAME                                                                          READY   STATUS    RESTARTS   AGE
calico-node-s9828                                                             2/2     Running   0          3m21s
calico-node-zc8qw                                                             2/2     Running   0          3m38s
coredns-6c7669957f-rvz85                                                      1/1     Running   0          3m38s
kube-apiserver-kube-control-plane-0-instance.devkubernetes01.mesos            1/1     Running   0          4m43s
kube-controller-manager-kube-control-plane-0-instance.devkubernetes01.mesos   1/1     Running   0          4m42s
kube-proxy-kube-control-plane-0-instance.devkubernetes01.mesos                1/1     Running   0          4m48s
kube-proxy-kube-node-0-kubelet.devkubernetes01.mesos                          1/1     Running   0          3m21s
kube-scheduler-kube-control-plane-0-instance.devkubernetes01.mesos            1/1     Running   0          4m26s
kubernetes-dashboard-5cbf45898-nkjsm                                          1/1     Running   0          3m37s
local-dns-dispatcher-kube-node-0-kubelet.devkubernetes01.mesos                1/1     Running   0          3m21s
metrics-server-594576c7d8-cb4pj                                               1/1     Running   0          3m35s
```

### Accessing the Kubernetes Dashboard

You will be able to access the Kubernetes Dashboard by running:

```bash
$ kubectl --context devkubernetes01 proxy
```

Then pointing your browser at:

```
http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

Please note that you will have to sign-in into the [Kubernetes Dashboard](https://docs.mesosphere.com/services/kubernetes/2.5.0-1.16.9/operations/kubernetes-dashboard/#login-view-and-authorization) before being able to perform any action.

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

For more details, please see the [docs folder](docs) and as well check the official [service docs](https://docs.mesosphere.com/service-docs/kubernetes/2.5.0-1.16.9)

## Community
Get help and connect with other users on the [mailing list](https://groups.google.com/a/dcos.io/forum/#!forum/kubernetes) or on DC/OS community [Slack](http://chat.dcos.io/) in the #kubernetes channel.

# Kubernetes on DC/OS

Kubernetes is now available as a DC/OS package to quickly, and reliably run Kubernetes clusters on Mesosphere DC/OS.

![](docs/assets/ui-install.gif)

**NOTE:** The latest `dcos-kubernetes-quickstart` doesn't support any Kubernetes framework version before `2.0.0-1.12.1`, now creating Kubernetes clusters requires the installation of the [Mesosphere Kubernetes Engine](https://docs.mesosphere.com/services/kubernetes/2.0.0-1.12.1/overview/#cluster-manager).

## Known limitations

Before proceeding, please check the [current package limitations](https://docs.mesosphere.com/service-docs/kubernetes/2.0.0-1.12.1/limitations/).

## Pre-Requisites

Check the requirements for running this quickstart:

* Linux or macOS
  * [Terraform 0.11.x](https://www.terraform.io/downloads.html). On MacOS, you can install with [brew](https://brew.sh/):
  ```bash
  $ brew install terraform
  ```
  * [Google Cloud](docs/gcp.md), [AWS](docs/aws.md) or [Azure](docs/azure.md)
  account with enough permissions to provide the needed infrastructure

* macOS
  * `watch`, you can install with brew:
  ```bash
  $ brew install watch
  ```
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
Now, edit said file and set the value `gcp_project` with your `project-id` and add your ssh file path to `gcp_ssh_pub_key_file` (the SSH public key, [`~/.ssh/google_compute_engine`](docs/gcp.md)), you will use to log-in into your new VMs later with the username `core`).

**WARNING:** Please, do not set a smaller instance (VM) type on the risk of failing to
install Kubernetes.

```
custom_dcos_download_path = "https://downloads.dcos.io/dcos/stable/1.12.0/dcos_generate_config.sh"
num_of_masters = "1"
num_of_private_agents = "4"
num_of_public_agents = "1"
#
gcp_project = "YOUR_GCP_PROJECT"
gcp_region = "us-central1"
gcp_ssh_pub_key_file = "/PATH/YOUR_GCP_SSH_PUBLIC_KEY.pub"
#
gcp_bootstrap_instance_type = "n1-standard-1"
gcp_master_instance_type = "n1-standard-8"
gcp_agent_instance_type = "n1-standard-8"
gcp_public_agent_instance_type = "n1-standard-8"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"
```

For more advanced scenarios, please check the [terraform-dcos documentation for Google Cloud](https://github.com/dcos/terraform-dcos/tree/master/gcp).

**NOTE:** The Kubernetes cluster is launched with default configurations, meaning without RBAC and no HA. Please read [Kubernetes Configurations](docs/k8s_configs.md) for details.

### Download command-line tools

If you haven't already, please download DC/OS client, `dcos` and Kubernetes
client, `kubectl`:

```bash
$ make get-cli
```

The `dcos` and `kubectl` binaries will be downloaded to the current working directory. 
It's up to you to decided whether or not to copy or move them to another path, e.g. a path included in `PATH`.

### Install

You are now ready to provision the DC/OS cluster and install the Kubernetes package:

```bash
$ make deploy
```

Terraform will now try and provision the infrastructure on your chosen cloud provider, and then proceed to install DC/OS.

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

Check the [exposing Kubernetes API doc](docs/exposing_kubernetes_api.md) to understand how the Kubernetes API gets exposed. 
To actually expose the Kubernetes API for the new Kubernetes cluster using Marathon-LB, run:

```bash
$ make marathon-lb
```

**NOTE:** Changing the file `.deploy/desired_cluster_profile` so that the number of `num_of_public_agents > 1` requires scaling`marathon-lb` service to the same number, enabling access to the Kubernetes API from all DC/OS public agents.

### Accessing the Kubernetes API

In order to access the Kubernetes API from outside the DC/OS cluster, one needs to configure `kubectl`, the Kubernetes CLI tool:

```bash
$ make kubeconfig
```

Let's test accessing the Kubernetes API and list the Kubernetes cluster nodes:

```bash
$ ./kubectl --context devkubernetes01 get nodes
NAME                                                  STATUS   ROLES    AGE     VERSION
kube-control-plane-0-instance.devkubernetes01.mesos   Ready    master   5m18s   v1.12.1
kube-node-0-kubelet.devkubernetes01.mesos             Ready    <none>   2m58s   v1.12.1
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

Please note that you will have to sign-in into the [Kubernetes Dashboard](https://docs.mesosphere.com/services/kubernetes/2.0.0-1.12.1/operations/kubernetes-dashboard/#login-view-and-authorization) before being able to perform any action.

## Uninstall Kubernetes

To uninstall the DC/OS Kubernetes package while leaving your DC/OS cluster up,
run:

```bash
$ make uninstall
```

**NOTE:** The above command will uninstall Kubernetes and supporting services like marathon-lb. 
Make sure you destroy your DC/OS cluster using the instructions below when you finish testing, or otherwise you will need to delete all cloud resources manually!

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

For more details, please see the [docs folder](docs) and as well check the official [service docs](https://docs.mesosphere.com/service-docs/kubernetes/2.0.0-1.12.1)

## Community
Get help and connect with other users on the [mailing list](https://groups.google.com/a/dcos.io/forum/#!forum/kubernetes) or on DC/OS community [Slack](http://chat.dcos.io/) in the #kubernetes channel.

## Roadmap for Kubernetes on DC/OS

* [ ] Automatic, and secure exposure of the Kubernetes API
* [ ] DC/OS as the cloud provider - fully integrated with DC/OS authentication, storage (CSI), and load-balancing (Service and Ingress)
* [ ] Node Pools - each pool has its own configuration, including placement constraints, taints and tolerations, etc.

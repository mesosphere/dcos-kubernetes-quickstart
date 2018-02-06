# Kubernetes on DC/OS

Kubernetes is now available as a DC/OS package to quickly, and reliably run Kubernetes clusters on Mesosphere DC/OS.

![](docs/assets/ui-install.gif)

**KUBERNETES ON DC/OS IS BETA, DO NOT USE IT FOR PRODUCTION CLUSTERS!**

**But, please try it out! Give us feedback at:**
**https://github.com/mesosphere/dcos-kubernetes-quickstart/issues**

## Known limitations

Before proceeding, please check the [current package limitations](https://docs.mesosphere.com/service-docs/beta-kubernetes/0.4.0-1.9.0-beta/limitations/).

## Pre-Requisites

First, make sure your cluster fulfils the [Kubernetes package default requirements](https://docs.mesosphere.com/service-docs/beta-kubernetes/0.4.0-1.9.0-beta/install/#prerequisites/).

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
Please, do not set a smaller instance (VM) type on the risk of failing to
install Kubernetes.

```
custom_dcos_download_path = "https://downloads.dcos.io/dcos/EarlyAccess/1.11.0-rc1/dcos_generate_config.sh"
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
Below is an example of how it looks like when the install ran successfully:

```bash
$ watch dcos task
```

After a while, you should see something like:
```
NAME                                HOST       USER  STATE  ID                                       MESOS ID
etcd-0-peer                         10.64.4.2  root    R    etcd-0-peer__xxx                         xxxxx-s2
etcd-1-peer                         10.64.4.4  root    R    etcd-1-peer__xxx                         xxxxx-S0
etcd-2-peer                         10.64.4.5  root    R    etcd-2-peer__xxx                         xxxxx-S3
kube-apiserver-0-instance           10.64.4.2  root    R    kube-apiserver-0-instance__xxx           xxxxx-S1
kube-apiserver-1-instance           10.64.4.4  root    R    kube-apiserver-1-instance__xxx           xxxxx-S0
kube-apiserver-2-instance           10.64.4.5  root    R    kube-apiserver-2-instance__xxx           xxxxx-S3
kube-controller-manager-0-instance  10.64.4.5  root    R    kube-controller-manager-0-instance__xxx  xxxxx-S3
kube-controller-manager-1-instance  10.64.4.2  root    R    kube-controller-manager-1-instance__xxx  xxxxx-S1
kube-controller-manager-2-instance  10.64.4.4  root    R    kube-controller-manager-2-instance__xxx  xxxxx-S0
kube-node-0-kube-proxy              10.64.4.5  root    S    kube-node-0-kube-proxy__xxx              xxxxx-S3
kube-node-0-kubelet                 10.64.4.5  root    S    kube-node-0-kubelet__xxx                 xxxxx-S3
kube-node-1-kube-proxy              10.64.4.2  root    S    kube-node-1-kube-proxy__xxx              xxxxx-S1
kube-node-1-kubelet                 10.64.4.2  root    S    kube-node-1-kubelet__xxx                 xxxxx-S1
kube-node-2-kube-proxy              10.64.4.4  root    S    kube-node-2-kube-proxy__xxx              xxxxx-S0
kube-node-2-kubelet                 10.64.4.4  root    S    kube-node-2-kubelet__xxx                 xxxxx-S0
kube-scheduler-0-instance           10.64.4.4  root    R    kube-scheduler-0-instance__xxx           xxxxx-S0
kube-scheduler-1-instance           10.64.4.2  root    R    kube-scheduler-1-instance__xxx           xxxxx-S1
kube-scheduler-2-instance           10.64.4.5  root    R    kube-scheduler-2-instance__xxx           xxxxx-S3
kubernetes                          10.64.4.4  root    R    kubernetes.xxx                           xxxxx-S0
```

### Accessing the DC/OS Dashboard

You can access DC/OS Dashboard and check Kubernetes package tasks under Services:

```bash
$ make ui
```

### Accessing the Kubernetes API

In order to access the Kubernetes API from outside the DC/OS cluster, one needs
to establish a reverse-tunnel through SSH to a DC/OS agent:

```bash
$ make kubectl-tunnel
```

When the `kube-apiserver-{}-instance` task(s) are healthy, the Kubernetes API
should be accessible on `http://localhost:9000`. Reaching this endpoint should show something like this:

```bash
$ curl http://localhost:9000
{
  "paths": [
    "/api",
    "/api/v1",
    "/apis",
    "/apis/",
    "/apis/admissionregistration.k8s.io",
    "/apis/admissionregistration.k8s.io/v1beta1",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1beta1",
    "/apis/apiregistration.k8s.io",
    "/apis/apiregistration.k8s.io/v1beta1",
    "/apis/apps",
    "/apis/apps/v1",
    "/apis/apps/v1beta1",
    "/apis/apps/v1beta2",
    "/apis/authentication.k8s.io",
    "/apis/authentication.k8s.io/v1",
    "/apis/authentication.k8s.io/v1beta1",
    "/apis/authorization.k8s.io",
    "/apis/authorization.k8s.io/v1",
    "/apis/authorization.k8s.io/v1beta1",
    "/apis/autoscaling",
    "/apis/autoscaling/v1",
    "/apis/autoscaling/v2beta1",
    "/apis/batch",
    "/apis/batch/v1",
    "/apis/batch/v1beta1",
    "/apis/certificates.k8s.io",
    "/apis/certificates.k8s.io/v1beta1",
    "/apis/events.k8s.io",
    "/apis/events.k8s.io/v1beta1",
    "/apis/extensions",
    "/apis/extensions/v1beta1",
    "/apis/networking.k8s.io",
    "/apis/networking.k8s.io/v1",
    "/apis/policy",
    "/apis/policy/v1beta1",
    "/apis/rbac.authorization.k8s.io",
    "/apis/rbac.authorization.k8s.io/v1",
    "/apis/rbac.authorization.k8s.io/v1beta1",
    "/apis/storage.k8s.io",
    "/apis/storage.k8s.io/v1",
    "/apis/storage.k8s.io/v1beta1",
    "/healthz",
    "/healthz/autoregister-completion",
    "/healthz/etcd",
    "/healthz/ping",
    "/healthz/poststarthook/apiservice-openapi-controller",
    "/healthz/poststarthook/apiservice-registration-controller",
    "/healthz/poststarthook/apiservice-status-available-controller",
    "/healthz/poststarthook/bootstrap-controller",
    "/healthz/poststarthook/ca-registration",
    "/healthz/poststarthook/generic-apiserver-start-informers",
    "/healthz/poststarthook/kube-apiserver-autoregistration",
    "/healthz/poststarthook/start-apiextensions-controllers",
    "/healthz/poststarthook/start-apiextensions-informers",
    "/healthz/poststarthook/start-kube-aggregator-informers",
    "/healthz/poststarthook/start-kube-apiserver-informers",
    "/logs",
    "/metrics",
    "/swagger-2.0.0.json",
    "/swagger-2.0.0.pb-v1",
    "/swagger-2.0.0.pb-v1.gz",
    "/swagger.json",
    "/swaggerapi",
    "/ui",
    "/ui/",
    "/version"
  ]
}
```

You are now ready to configure `kubectl`, the Kubernetes CLI tool:

```bash
$ make kubectl-config
```

Let's test accessing the Kubernetes API and list the Kubernetes cluster nodes:

```bash
$ kubectl get nodes
NAME                                          STATUS    ROLES     AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos          Ready     <none>    8m        v1.9.0
kube-node-1-kubelet.kubernetes.mesos          Ready     <none>    8m        v1.9.0
kube-node-2-kubelet.kubernetes.mesos          Ready     <none>    8m        v1.9.0
kube-node-public-0-kubelet.kubernetes.mesos   Ready     <none>    7m        v1.9.0
```

## Destroy cluster

To destroy the whole deployment:

```bash
$ make destroy
```

Alternatively, you can separately uninstall Kubernetes:

```bash
$ make uninstall
```

And delete the DC/OS cluster:

```bash
$ make destroy-dcos
```

**ATTENTION:** Make sure to run `make destroy-dcos` or otherwise you will need to delete all cloud resources manually!

Last, clean generated resources:
```
make clean
```

## Documentation

For more details, please see the [docs folder](docs) and as well check the official [service docs](https://docs.mesosphere.com/service-docs/beta-kubernetes/0.4.0-1.9.0-beta)

## Community
Get help and connect with other users on the [mailing list](https://groups.google.com/a/dcos.io/forum/#!forum/kubernetes) or on DC/OS community [Slack](http://chat.dcos.io/) in the #kubernetes channel.

## Roadmap

Kubernetes on DC/OS is currently in Beta, and not recommended for Production.  For Production certification, we will be delivering incremental functionality:

- [x] Helm Support
- [ ] Provide better option than SSH tunnel for API server authentication
- [x] Robust external ingress for Kubernetes Services
- [ ] Ability to dynamically expand the Kubernetes nodes
- [ ] Non-disruptive Kubernetes version upgrades
- [x] Disaster Recovery
- [ ] Cloud-provider integration
  - [x] AWS
  - [ ] Google Cloud
  - [ ] Azure

In the future, we will be open-sourcing the underlying Kubernetes framework code.  Stay tuned for details.

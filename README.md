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

* [Terraform 0.11.x](https://www.terraform.io/downloads.html). On MacOS, you can use [brew](https://brew.sh/) for that.
```
brew install terraform
```
* Google Cloud (GCE) [SDK](docs/gce.md)
* [AWS](docs/aws.md) and [Azure](docs/azure.md) are supported as well
* Linux/Mac machine to execute the samples below

Note that default templates are defined to deploy the virtual machines in
the [resources](resources/) directory. You can customize these templates to your
needs.

## Quickstart

Once the above pre-requisites have been met, clone this repo.

```
git clone git@github.com:mesosphere/dcos-kubernetes-quickstart.git && cd dcos-kubernetes-quickstart
```

**For this Quickstart we are going to use GCE cloud provider**

Install and setup Google Cloud SDK as per [doc](docs/gce.md).

### Configure cluster

Set GCP as cloud provider.
```
make gce
```
The command above will download necessary [Terraform files](https://github.com/dcos/terraform-dcos/tree/master/gcp) to `.deploy` folder.

Make updates to `.deploy/desired_cluster_profile` with your GCP `project-id` and `ssh key`, please do not change VMs to lower spec type, as then Kubernetes install will fail.
```
vi .deploy/desired_cluster_profile
dcos_version = "1.10.2"
num_of_masters = "1"
num_of_private_agents = "3"
num_of_public_agents = "1"
#
google_project = "YOUR_GCP_PROJECT"
google_region = "us-central1"
gce_ssh_pub_key_file = "PATH/YOUR_GCP_SSH_PUBLIC_KEY.pub"
#
gcp_bootstrap_instance_type = "n1-standard-1"
gcp_master_instance_type = "n1-standard-8"
gcp_agent_instance_type = "n1-standard-8"
gcp_public_agent_instance_type = "n1-standard-8"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"
```

For more cluster setup tweaks check out [here](https://github.com/dcos/terraform-dcos/tree/master/gcp).

### Download command-line tools

Download DC/OS cli `dcos` and Kubernetes `kubectl`.
```
make get-cli
```

Files `dcos` and `kubectl` will be downloaded to the current folder, please move them for example, to  `/usr/local/bin/`, or any other folder set in your shell's `path`, so they can be invoked later one by install.

### Install cluster

You are now ready to create a DC/OS cluster.

Pre-check install.
```
make plan
```

Install cluster.
```
make deploy
```

Terraform will now try and provision the infrastructure on your chosen cloud-provider and then proceed to install DC/OS. When DC/OS is up and running, the Kubernetes package will get installed then.

Then wait till Kubernetes package all tasks get installed.
```
watch dcos task
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

### Connecting to Kubernetes API Server

In order to access the Kubernetes API from outside the DC/OS cluster, one needs SSH access to a node-agent.
```
make  kubectl-tunnel
```

When the Kubernetes API task(s) are healthy, it should be accessible on `http://localhost:9000`. Reaching this endpoint should show something like this:

```bash
$ curl http://localhost:9000
{
  "paths": [
    "/api",
    "/api/v1",
    "/apis",
    "/apis/apps",
    "/apis/apps/v1beta1",
    "/apis/authentication.k8s.io",
    "/apis/authentication.k8s.io/v1",
    "/apis/authentication.k8s.io/v1beta1",
    "/apis/authorization.k8s.io",
    "/apis/authorization.k8s.io/v1",
    "/apis/authorization.k8s.io/v1beta1",
    "/apis/autoscaling",
    "/apis/autoscaling/v1",
    "/apis/autoscaling/v2alpha1",
    "/apis/batch",
    "/apis/batch/v1",
    "/apis/batch/v2alpha1",
    "/apis/certificates.k8s.io",
    "/apis/certificates.k8s.io/v1beta1",
    "/apis/extensions",
    "/apis/extensions/v1beta1",
    "/apis/policy",
    "/apis/policy/v1beta1",
    "/apis/rbac.authorization.k8s.io",
    "/apis/rbac.authorization.k8s.io/v1alpha1",
    "/apis/rbac.authorization.k8s.io/v1beta1",
    "/apis/settings.k8s.io",
    "/apis/settings.k8s.io/v1alpha1",
    "/apis/storage.k8s.io",
    "/apis/storage.k8s.io/v1",
    "/apis/storage.k8s.io/v1beta1",
    "/healthz",
    "/healthz/ping",
    "/healthz/poststarthook/bootstrap-controller",
    "/healthz/poststarthook/ca-registration",
    "/healthz/poststarthook/extensions/third-party-resources",
    "/logs",
    "/metrics",
    "/swaggerapi/",
    "/ui/",
    "/version"
  ]
}
```

We are now ready to configure `kubectl`, the Kubernetes CLI tool.
```
make kubectl-config
```

Which will set cluster context.
```
kubectl config set-cluster dcos-k8s --server=http://localhost:9000
kubectl config set-context dcos-k8s --cluster=dcos-k8s --namespace=default
kubectl config use-context dcos-k8s
```

Test access by retrieving the Kubernetes cluster nodes:
```bash
$ kubectl get nodes
NAME                                   STATUS    AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos   Ready     7m        v1.9.0
kube-node-1-kubelet.kubernetes.mesos   Ready     7m        v1.9.0
kube-node-2-kubelet.kubernetes.mesos   Ready     7m        v1.9.0
```

### Deploy Kubernetes workloads on DCOS

To deploy your first Kubernetes workloads on DC/OS, please see the [examples folder](examples/README.md)

### Adding DC/OS agents

If you would like to add more or remove (private) agents or public agents from your cluster, edit `.deploy/desired_cluster_profile` and then run.
```
make upgrade-infra
```

You can read more about adding/removing agents [here](https://github.com/dcos/terraform-dcos/tree/master/gcp#maintenance).

### Upgrading DC/OS

When the new DC/OS version is released edit `.deploy/desired_cluster_profile` and then run.
```
make upgrade-dcos
```

You can read more about DC/OS upgrade [here](https://github.com/dcos/terraform-dcos/tree/master/gcp#upgrading-dcos).

### Destroy cluster

Uninstall Kubernetes.
```
make uninstall
```

Delete the DC/OS cluster.
```
make destroy-dcos
```

Clean up.
**Note:** Make sure to run `make destroy-dcos` before this, as otherwise you will need to delete all cloud resources manually!.
```
make clean
```

## Documents

For more details, please see the [docs folder](docs) and as well check the official [service docs](https://docs.mesosphere.com/service-docs/beta-kubernetes/0.4.0-1.9.0-beta)

## Community
Get help and connect with other users on the [mailing list](https://groups.google.com/a/dcos.io/forum/#!forum/kubernetes) or on DC/OS community [Slack](http://chat.dcos.io/) in the #kubernetes channel.

## Roadmap

Kubernetes on DC/OS is currently in Beta, and not recommended for Production.  For Production certification, we will be delivering incremental functionality:

- [x] Helm Support
- [ ] Provide better option than SSH tunnel for API server authentication (needs DC/OS 1.11)
- [x] Robust external ingress for Kubernetes Services
- [ ] Ability to dynamically expand the Kubernetes nodes
- [ ] Non-disruptive Kubernetes version upgrades
- [x] Disaster Recovery
- [ ] Cloud-provider integration
  - [x] AWS
  - [ ] Google Cloud
  - [ ] Azure

In the future, we will be open-sourcing the underlying Kubernetes framework code.  Stay tuned for details.

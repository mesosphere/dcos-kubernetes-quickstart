# Kubernetes on DC/OS

Kubernetes is now available as a DC/OS package to quickly, and reliably run Kubernetes clusters on Mesosphere DC/OS.

![](docs/assets/ui-install.gif)

**KUBERNETES ON DC/OS  IS BETA, DO NOT USE IT FOR PRODUCTION CLUSTERS!**

**But, please try it out! Give us feedback at:**
**https://github.com/mesosphere/dcos-kubernetes-quickstart/issues**

## Pre-Requisites

* Google Cloud (GCE) credentials ([AWS](docs/aws.md) and [Azure](docs/azure.md) are supported as well) with the necessary [permissions](docs/gce-service-account.md)
* Linux/Mac machine to execute the samples below
* Docker CE 17+

## Quickstart

You are now ready to create a DC/OS cluster.

Once the above pre-requisites have been met, clone this repo.

```
git clone git@github.com:mesosphere/dcos-kubernetes-quickstart.git && cd dcos-kubernetes-quickstart
```

Set your GCE credentials as environment variables. More information on how to obtain
you credentials can be found [here](https://developers.google.com/identity/protocols/application-default-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=<PATH TO YOUR CREDENTIAL FILE>
```

The remainder of this quick-start will execute in a Docker container, and create your cluster on GCE, with Kubernetes configured.  Simply run

```
$ make docker
```

You are now in a container from which you will deploy the cluster and required tools.

```
$ make deploy
# Installation might take ~ 8minutes.

# Creates a ssh tunnel to a node-agent for APIServer access.
$ make kubectl-tunnel
# Make sure the API Server and Kubelets are up by running:
$ kubectl get nodes

# If you see a result like this, everything is working properly, and you are now running Kubernetes on DC/OS.

NAME                                   STATUS    AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos   Ready     13s       v1.7.5
kube-node-1-kubelet.kubernetes.mesos   Ready     13s       v1.7.5
kube-node-2-kubelet.kubernetes.mesos   Ready     13s       v1.7.5

make uninstall
# Uninstalls kubernetes.
make destroy-dcos
# Deletes the DC/OS cluster.
```

## Installing DC/OS CLI

The recommended method to install the DC/OS CLI is from the DC/OS web interface. Or, you can manually install the CLI by using the instructions below.

Installing the DC/OS CLI on [Linux](https://dcos.io/docs/1.10/cli/install/#linux)

Installing the DC/OS CLI on [macOS](https://dcos.io/docs/1.10/cli/install/#osx)


## Installing Kubectl

Use the Kubernetes command-line tool, kubectl, to deploy and manage applications on Kubernetes. Using kubectl, you can inspect cluster resources; create, delete, and update components; and look at your new cluster and bring up example apps.

Follow instructions [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to download.

## Connecting to Kubernetes APIServer

In order to access the Kubernetes API from outside the DC/OS cluster, one needs SSH access to a node-agent.
On a terminal window, run:

```bash
ssh -N -L 9000:apiserver-insecure.kubernetes.l4lb.thisdcos.directory:9000 <USER>@<HOST>
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

We are now ready to install and configure `kubectl`, the Kubernetes CLI tool. For the sake of simplicity, we'll be covering the set-up alone:
```bash
kubectl config set-cluster dcos-k8s --server=http://localhost:9000
kubectl config set-context dcos-k8s --cluster=dcos-k8s --namespace=default
kubectl config use-context dcos-k8s
```

Test access by retrieving the Kubernetes cluster nodes:
```bash
$ kubectl get nodes
NAME                                   STATUS    AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos   Ready     7m        v1.7.5
kube-node-1-kubelet.kubernetes.mesos   Ready     7m        v1.7.5
kube-node-2-kubelet.kubernetes.mesos   Ready     7m        v1.7.5
```

## Deploy Kubernetes workloads on DCOS

To deploy your first Kubernetes workloads on DC/OS, please see the [examples folder](examples/README.md)

## Documents

For more details, please see the [docs folder](docs) as well was the official [service docs](https://docs.mesosphere.com/service-docs/beta-kubernetes/0.2.0-1.7.6-beta)

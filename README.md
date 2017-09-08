# Kubernetes on DC/OS

Kubernetes is now available as a DC/OS package to quickly, and reliably run Kubernetes clusters on Mesosphere DC/OS.

![](assets/ui-install.gif)


## Pre-Requisites

* Google Cloud (GCE) credentials ([AWS](docs/aws.md) is supported as well) with the necessary [permissions](docs/gce_permissions.md)
* Linux/Mac machine to execute the samples below
* Docker CE 17+

## Quickstart

You are now ready to create a DC/OS cluster.

Once the above pre-requisites have been met, clone this repo.

```
git clone git@github.com:mesosphere/dcos-kubernetes-quickstart.git && cd dcos-kubernetes-quickstart
```

Set your GCE credentials as environment variables.  

```
export GOOGLE_APPLICATION_CREDENTIALS=<PATH TO YOUR CREDENTIAL FILE>
```

The remainder of this quick-start will execute in a Docker container, and create your cluster on GCE, with Kubernetes configured.  Simply run

```
When it completes, connect to the 
make docker
# You are now in a container
make launch-dcos 
# Launches DC/OS cluster. The cluster provisioning will take ~15 minutes.  
make setup-cli 
# Configures the DC/OS CLI and kubectl
make install 
# Installs kubernetes on your cluster. Takes ~2 minutes
make kubectl-tunnel 
# Creates a ssh tunnel to a node-agent for APIServer access
# Make sure the API Server and Kubelet's are up by running:

kubectl get nodes

# If you see a result like this, everything is working properly, and you are now running Kubernetes on DC/OS

NAME                                   STATUS    AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos   Ready     13s       v1.7.5 
kube-node-1-kubelet.kubernetes.mesos   Ready     13s       v1.7.5 
kube-node-2-kubelet.kubernetes.mesos   Ready     13s       v1.7.5 

make uninstall 
# Uninstalls kubernetes
make destroy-dcos 
# Deletes the DC/OS cluster
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

## Mandatory add-ons

**NOTE:** As of this moment, only `kube-dns` is a mandatory plug-in.

Assuming one has a working Kubernetes cluster with enough available resources, here's how to install the add-on:
```bash
kubectl create -f add-ons/dns/kubedns-cm.yaml
kubectl create -f add-ons/dns/kubedns-svc.yaml
kubectl create -f add-ons/dns/kubedns-deployment.yaml
```

**NOTE:** The Kubernetes namespace where `kube-dns` will be running is `kube-system` and not `default`.

A successfull deployment should look like the following:
```bash
$ kubectl -n kube-system get deployment,pods
NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/kube-dns   1         1         1            1           1h

NAME                           READY     STATUS    RESTARTS   AGE
po/kube-dns-1115425399-mwsn8   3/3       Running   0          1h
```

And a Kubernetes service should be exposed on `10.100.0.10` with at least one endpoint (pod):
```bash
$ kubectl -n kube-system describe svc kube-dns
Name:			kube-dns
Namespace:		kube-system
Labels:			k8s-app=kube-dns
			kubernetes.io/cluster-service=true
			kubernetes.io/name=KubeDNS
Annotations:		<none>
Selector:		k8s-app=kube-dns
Type:			ClusterIP
IP:			10.100.0.10
Port:			dns	53/UDP
Endpoints:		9.0.2.5:53
Port:			dns-tcp	53/TCP
Endpoints:		9.0.2.5:53
Session Affinity:	None
Events:			<none>
```

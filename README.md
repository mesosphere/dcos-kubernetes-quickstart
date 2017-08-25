# Kubernetes on DC/OS

Kubernetes is now available as a DC/OS package to quickly, and reliably run Kubernetes clusters on Mesosphere DC/OS.

<video src="assets/ui-install.gif" width="320" height="200" controls preload></video>

## Pre-Requisites

* Google Cloud (GCE) credentials ([AWS](docs/aws.md) is supported as well) with the necessary [permissions](docs/gce_permissions.md)
* Linux/Mac machine to execute the samples below
* Docker CE 17+

## Quickstart

You are now ready to create a 5 node DC/OS cluster.

Once the above pre-requisites have been met, clone this repo.

```
git clone git@github.com:mesosphere/dcos-kubernetes-quickstart.git && cd dcos-kubernetes-quickstart
```

Set your GCE credentials as environment variables

```
TODO
```

The remainder of this quick-start will execute in a Docker container, and create your cluster on GCE, with Kubernetes configured.  Simply run

```
make docker
# you are now in a container
make all
# The cluster provisioning will take ~15 minutes.  When it completes, connect to the 
# Kubernetes API Server
# Make sure the API Server and Kubelet's are up

kubectl get nodes

# If you see a result like this, everything is working properly, and you are now running Kubernetes on DC/OS

NAME                                   STATUS    AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos   Ready     2m        v1.7.3
kube-node-1-kubelet.kubernetes.mesos   Ready     2m        v1.7.3
kube-node-2-kubelet.kubernetes.mesos   Ready     2m        v1.7.3
```


# Kubernetes on DC/OS

Kubernetes is now available as a DC/OS package to quickly, and reliably run Kubernetes clusters on Mesosphere DC/OS.

![](assets/ui-install.gif)


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

Set your GCE credentials as environment variables.  

```
export GOOGLE_APPLICATION_CREDENTIALS=<PATH TO YOUR CREDENTIAL FILE>
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

## Installing DC/OS CLI

The recommended method to install the DC/OS CLI is from the DC/OS web interface. Or, you can manually install the CLI by using the instructions below.

## Mandatory add-ons

**NOTE:** As of this moment, only `kube-dns` is a mandatory plug-in.

**ATTENTION:** DNS integration needs [DC/OS cluster DNS to be properly configured](#spartan-config).

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

As the last step, let's try resolving the following from within a debugging pod:
* the Kubernetes API service hostname,
* the Kubernetes API DC/OS VIP hostname,
* a Mesos task,
* a public hostname

```bash
$ kubectl run -i --tty dns-debug --image=busybox --restart=Never -- sh
If you don't see a command prompt, try pressing enter.
/ #

/ # nslookup kubernetes
Server:    10.100.0.10                                              
Address 1: 10.100.0.10 kube-dns.kube-system.svc.cluster.local       
                                                                    
Name:      kubernetes                                               
Address 1: 10.100.0.1 kubernetes.default.svc.cluster.local          

/ # nslookup apiserver.kubernetes.l4lb.thisdcos.directory
Server:    198.51.100.1
Address 1: 198.51.100.1

Name:      apiserver.kubernetes.l4lb.thisdcos.directory
Address 1: 11.53.156.245

/ # nslookup etcd-0-peer.kubernetes.mesos
Server:    198.51.100.1
Address 1: 198.51.100.1

Name:      etcd-0-peer.kubernetes.mesos
Address 1: 10.142.0.6 pires-9a4ba9de-private-agents-hl4j.c.massive-bliss-781.internal

/ # nslookup mesosphere.com
Server:    198.51.100.1
Address 1: 198.51.100.1

Name:      mesosphere.com
Address 1: 54.230.204.38 server-54-230-204-38.atl50.r.cloudfront.net
Address 2: 54.230.204.60 server-54-230-204-60.atl50.r.cloudfront.net
Address 3: 54.230.204.12 server-54-230-204-12.atl50.r.cloudfront.net
Address 4: 54.230.204.98 server-54-230-204-98.atl50.r.cloudfront.net
Address 5: 54.230.204.121 server-54-230-204-121.atl50.r.cloudfront.net
Address 6: 54.230.204.35 server-54-230-204-35.atl50.r.cloudfront.net
Address 7: 54.230.204.8 server-54-230-204-8.atl50.r.cloudfront.net
Address 8: 54.230.204.52 server-54-230-204-52.atl50.r.cloudfront.net

exit
```

Don't forget to delete the completed debugging pod.
```bash
kubectl delete pod dns-debug
```

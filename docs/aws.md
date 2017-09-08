# AWS Cluster

The easiest way to get started on AWS is by setting environment variables with your access keys.

```
export AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY>
export AWS_SECRET_ACCESS_KEY=<YOUR SECRET KEY>
```

You can then pass the platform variable to the `launch-dcos` command

```
make docker
# You are now in a container.
make launch-dcos PLATFORM=aws 
# Launches DC/OS cluster. The cluster provisioning will take ~15 minutes.  
make setup-cli 
# Configures the DC/OS CLI and kubectl.
make install 
# Installs kubernetes on your cluster. Takes ~2 minutes.
make kubectl-tunnel PLATFORM=aws 
# Creates a ssh tunnel to a node-agent for APIServer access.
# Make sure the API Server and Kubelets are up by running:

kubectl get nodes

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
```
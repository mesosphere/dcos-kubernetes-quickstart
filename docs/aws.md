# AWS Cluster

The easiest way to get started on AWS is by setting environment variables with your access keys.

```
export AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY>
export AWS_SECRET_ACCESS_KEY=<YOUR SECRET KEY>
```

Note that, you could experience some issues due to insufficient resource limits of your account. You can verify your default limits [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-resource-limits.html).

You can then pass the platform variable to the `launch-dcos` command

```
# Build and enter working container.
make docker

# Launches DC/OS cluster. The cluster provisioning will take ~15 minutes.
make launch-dcos PLATFORM=aws

# Configure the DC/OS CLI and kubectl.
make setup-cli

# Install DC/OS Kubernetes package.
make install

# Create a ssh tunnel to a node-agent for Kubernetes API access.
make kubectl-tunnel PLATFORM=aws

# Make sure the Kubernetes API and Kubernetes nodes are up by running:
kubectl get nodes

# If you see a result like this, everything is working properly, and you are now running Kubernetes on DC/OS.

NAME                                   STATUS    AGE       VERSION
kube-node-0-kubelet.kubernetes.mesos   Ready     2m       v1.9.0
kube-node-1-kubelet.kubernetes.mesos   Ready     2m       v1.9.0
kube-node-2-kubelet.kubernetes.mesos   Ready     2m       v1.9.0

# Uninstall kubernetes.
make uninstall

# Delete the DC/OS cluster.
make destroy-dcos
```

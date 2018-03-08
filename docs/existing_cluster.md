# Existing Cluster

If you already have a DC/OS 1.11+ cluster, Kubernetes is publicly available in the Catalog.

Before proceeding, please ensure your cluster satisfies the minimum [resource requirements](https://docs.mesosphere.com/service-docs/kubernetes/1.0.0-1.9.3/install/#prerequisites/)

Then, install is as easy as:

```
dcos package install kubernetes
```

By default, it will provision a Kubernetes cluster with three (3) worker nodes.

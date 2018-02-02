# Existing Cluster

If you already have a DC/OS 1.11+ cluster, Kubernetes is publicly available in the Catalog.

Before proceeding, please ensure your cluster satisfies the minimum [resource requirements](https://docs.mesosphere.com/service-docs/beta-kubernetes/0.4.0-1.9.0-beta/install/#prerequisites/)

Then, install is as easy as:

```
dcos package install beta-kubernetes
```

By default, it will provision a Kubernetes cluster with three (3) worker nodes.

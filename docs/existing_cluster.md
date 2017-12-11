# Existing Cluster

If you already have a DC/OS 1.10+ cluster, Kubernetes is publicly available in the Catalog.
Please ensure your cluster satisfies the minimum [resource requirements](https://docs.mesosphere.com/service-docs/beta-kubernetes/0.3.1-1.7.11-beta/install/#prerequisites/)

```
dcos package install beta-kubernetes
```

This will create a 3 node Kubernetes cluster via DC/OS.

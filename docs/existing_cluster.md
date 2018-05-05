# Existing Cluster

If you already have a DC/OS 1.11+ cluster, Kubernetes is publicly available in the Catalog.

Before proceeding, please ensure your cluster satisfies the minimum [resource requirements](https://docs.mesosphere.com/service-docs/kubernetes/1.0.3-1.9.7/install/#prerequisites/)

Then, install is as easy as:

```shell
$ dcos package install kubernetes
```

## Kubernetes configuration

**NOTE:** By default, it will provision a Kubernetes cluster with one (1) worker node, and
a single instance of every control plane component.

To deploy a **highly-available** cluster with three (3) private and one (1) public workers node update, run:

```shell
$ dcos package install --options=./resources/options-ha.json kubernetes
```

# Kubernetes Configuration

#### RBAC

**NOTE:** This `quickstart` will provision a Kubernetes cluster without `RBAC` support.

To deploy a cluster with enabled [RBAC](https://docs.mesosphere.com/services/kubernetes/2.0.0-1.12.1/operations/authn-and-authz/#rbac) update `.deploy/options.json`:

```
{
  "service": {
    "name": "dev/kubernetes01"
  },
  "kubernetes": {
    "authorization_mode": "RBAC"
  }
}
```

If you want to give users access to the Kubernetes API check [documentation](https://docs.mesosphere.com/services/kubernetes/2.0.0-1.12.1/operations/authn-and-authz/#giving-users-access-to-the-kubernetes-api).

**NOTE:** The authorization mode for a cluster must be chosen when installing the package. 
Changing the authorization mode after installing the package is not supported.

#### HA Cluster

**NOTE:** By default, it will provision a Kubernetes cluster with one (1) worker node, and a single instance of every control plane component.

To deploy a **highly-available** cluster with three (3) private Kubernetes nodes update `.deploy/options.json`:

```
{
  "service": {
    "name": "dev/kubernetes01"
  },
  "kubernetes": {
    "high_availability": true,
    "private_node_count": 3
  }
}
```

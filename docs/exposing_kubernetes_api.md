# Exposing the Kubernetes API

DC/OS Kubernetes doesn’t automatically expose the Kubernetes API outside of the DC/OS cluster.
It can be achieved using Marathon-LB and dummy marathon application.

## Using Marathon-LB instance

Marathon-LB instance and dummy `kubeapi-proxy` marathon application get installed as part of Kubernetes
framework install. This allows to expose Kubernetes API via DC/OS public agent IP.

The dummy Marathon application `kubeapi-proxy` definition:

```json
{
  "id": "/kubeapi-proxy",
  "instances": 1,
  "cpus": 0.001,
  "mem": 16,
  "cmd": "tail -F /dev/null",
  "container": {
    "type": "MESOS"
  },
  "portDefinitions": [
    {
      "protocol": "tcp",
      "port": 0
    }
  ],
  "labels": {
    "HAPROXY_GROUP": "external",
    "HAPROXY_0_MODE": "http",
    "HAPROXY_0_PORT": "6443",
    "HAPROXY_0_SSL_CERT": "/etc/ssl/cert.pem",
    "HAPROXY_0_BACKEND_SERVER_OPTIONS": "  timeout connect 10s\n  timeout client 86400s\n  timeout server 86400s\n  timeout tunnel 86400s\n  server kube-apiserver apiserver.devkubernetes01.l4lb.thisdcos.directory:6443 ssl verify none\n"   
  }
}
```

Here is how this works:
1. Marathon-LB identifies that the application `kubeapi-proxy` has the `HAPROXY_GROUP` label set to `external` (change this if you're using a different `HAPROXY_GROUP` for your Marathon-LB configuration).
1. The `instances`, `cpus`, `mem`, `cmd`, and `container` fields basically create a dummy container that takes up minimal space and performs no operation.
1. The single port indicates that this application has one "port" (this information is used by Marathon-LB)
1. `"HAPROXY_0_MODE": "http"` indicates to Marathon-LB that the frontend and backend configuration for this particular service should be configured with `http`.
1. `"HAPROXY_0_PORT": "6443"` tells Marathon-LB to expose the service on port 6443 (rather than the randomly-generated service port, which is ignored)
1. `"HAPROXY_0_SSL_CERT": "/etc/ssl/cert.pem"` tells Marathon-LB to expose the service with the self-signed Marathon-LB certificate (which has **no CN**)
1. The last label `HAPROXY_0_BACKEND_SERVER_OPTIONS` indicates that Marathon-LB should forward traffic to the endpoint `apiserver.kubernetes.l4lb.thisdcos.directory:6443` rather than to the dummy application, and that the connection should be made using TLS without verification.

For more options of exposing Kubernetes API, please check the [documentation](https://docs.mesosphere.com/services/kubernetes/2.3.0-1.14.1/operations/exposing-the-kubernetes-api/).

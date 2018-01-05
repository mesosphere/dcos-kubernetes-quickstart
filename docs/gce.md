# Google Cloud Platform

## Install Google Cloud SDK

Install Cloud [SDK](https://cloud.google.com/sdk/downloads).

Run this command to authenticate to the Google Provider. This will bring down your keys locally on the machine for terraform to use.

```
$ gcloud auth login
$ gcloud auth application-default login
```

### Configure your GCP ssh Keys

Set the private key that you will be you will be using to your ssh-agent and set public key in terraform. You can find GCP documentation that talks about this [here](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys).

When you have your key available, you can use ssh-add.

```bash
ssh-add ~/.ssh/google_compute_engine.pub
```

## Cloud Provider Resource Quotas

When deploying our cluster, you might experience some issues related to insufficient resource limits. Consequently, we recommend to verify your default limits [here](https://cloud.google.com/compute/quotas).

# Cluster install

Follow steps from the main [readme](../README.md#configure-cluster)

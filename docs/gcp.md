# Google Cloud

**WARNING**: When running this quickstart, you might experience some issues
with cloud resource limits. Please, verify your [quotas](https://cloud.google.com/compute/quotas)
before proceeding.

## Install Google Cloud SDK

Make sure to have previously installed [Google Cloud SDK](https://cloud.google.com/sdk/downloads).

## Setup access

First, you need to retrieve the credentials needed for Terraform to manage your
Google Cloud resources:

```bash
$ gcloud auth login
$ gcloud auth application-default login
```

Next, you need to setup SSH as per [official documentation](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys).

Add the SSH private key:

```bash
$ ssh-add ~/.ssh/google_compute_engine
```

Later, you will be asked to add the SSH public key to the Terraform cluster profile.

## Install

It's time to [bootstrap your Kubernetes cluster](../README.md#install).

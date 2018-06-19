# Google Cloud

**WARNING**: When running this quickstart, you might experience some issues
with cloud resource limits. Please, verify your [quotas](https://cloud.google.com/compute/quotas)
before proceeding.

## Install Google Cloud SDK

Make sure to have previously installed [Google Cloud SDK](https://cloud.google.com/sdk/downloads).

### Setup access

First, you need to retrieve the credentials needed for Terraform to manage your
Google Cloud resources:

```bash
$ gcloud auth login
$ gcloud auth application-default login
```

## Google Cloud Service Account

If you want to use GCP Service Account key instead of GCP SDK, uncomment the line as shown below in `desired_cluster_profile` and update it with the path to the ssh key file:

```
...
gcp_credentials_key_file = "/PATH/YOUR_GCP_SERVICE_ACCOUNT_KEY.json"
...

```

## Setup SSH key

Next, you need to setup SSH as per [official GCP documentation](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys) if you setup Google Cloud SDK or Google Cloud Service Account.

Add the SSH private key:

```bash
$ ssh-add ~/.ssh/google_compute_engine
```

Later, you will be asked to add the SSH public key to the Terraform cluster profile.

## Infrastructure configuration

Let's  move on to [infrastructure configuration](../README.md#prepare-infrastructure-configuration).

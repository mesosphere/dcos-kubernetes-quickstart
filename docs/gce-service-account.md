# Google Cloud Platform Service Account

A service account represents a Google Cloud service identity, such as code running on Compute Engine VMs.

To retrieve the credential file from Google Cloud, request a key

```
gcloud iam service-accounts keys create key.json --iam-account=nick-960@cool-project-781.iam.gserviceaccount.com

```
You can find more information on how to create a service account [here](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances). Note the location of this downloaded key as you will use it to provision a GCE cluster.

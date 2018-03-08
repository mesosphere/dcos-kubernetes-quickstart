# Azure

**WARNING**: When running this quickstart, you might experience some issues
with cloud resource limits. Please, verify your [quotas](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits)
before proceeding.

## Install Azure CLI

Make sure to have previously installed [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

## Setup access

First, you should be able to list your Azure account:

```bash
$ az account list
```

Next, you need to retrieve the credentials needed for Terraform to manage your
Azure resources.
In order to do so, follow the [official Terraform instructions for Azure](https://www.terraform.io/docs/providers/azurerm/#creating-credentials).

Before proceeding, we recommend you create a file with your Azure credentials,
so you can [`source`](http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x237.html) it later,
in between shell sessions:

```bash
$ cat << EOF > ~/.azure/my_credentials
export ARM_TENANT_ID=45ef06c1-a57b-40d5-967f-12345
export ARM_CLIENT_SECRET=Lqw0kyzWXyEjfha9hfhs12345jpJUIGQhNFExAmPLE
export ARM_CLIENT_ID=80f99c3a-cd7d-4931-9405-12345
export ARM_SUBSCRIPTION_ID=846d9e22-a320-488c-92d5-12345
EOF
```

## Prepare infrastructure configuration

Make sure Terraform knows where to find your Azure credentials:

```bash
$ source ~/.azure/my_credentials
```

Now, let's generate the default infrastructure configuration:

```bash
$ make azure
```

This will output sane defaults to `.deploy/desired_cluster_profile`.
Now, edit said file and set `ssh_pub_key`, the public SSH key you will use to
log-in into your new VMs later.

**WARNING:** Please, do not set a smaller instance (VM) type on the risk of
failing to install Kubernetes.

```
custom_dcos_download_path = "https://downloads.dcos.io/dcos/stable/1.11.0/dcos_generate_config.sh"
num_of_masters = "1"
num_of_private_agents = "3"
num_of_public_agents = "1"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"
ssh_pub_key = "INSERT_AZURE_PUBLIC_KEY_HERE"
```

For more advanced scenarios, please check the [terraform-dcos documentation for Azure](https://github.com/dcos/terraform-dcos/tree/master/azure).

## Install

It's time to [bootstrap your Kubernetes cluster](../README.md#install).

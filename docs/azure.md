# Azure Cloud Provider

## Configure Credentials

### Configure your Azure ssh Keys

Set the private key that you will be you will be using to your ssh-agent and set public key in terraform.

```bash
ssh-add ~/.ssh/your_private_azure_key.pem
```

Add your Azure ssh key to `desired_cluster_profile` file:
```
ssh_pub_key = "INSERT_AZURE_PUBLIC_KEY_HERE"
```

### Configure your Azure ID Keys

Follow the Terraform instructions [here](https://www.terraform.io/docs/providers/azurerm/#creating-credentials) to setup your Azure credentials to provide to terraform.

When you've successfully retrieved your output of `az account list`, create a source file to easily run your credentials in the future.

```
$ cat ~/.azure/credentials
export ARM_TENANT_ID=45ef06c1-a57b-40d5-967f-88cf8example
export ARM_CLIENT_SECRET=Lqw0kyzWXyEjfha9hfhs8dhasjpJUIGQhNFExAmPLE
export ARM_CLIENT_ID=80f99c3a-cd7d-4931-9405-8b614example
export ARM_SUBSCRIPTION_ID=846d9e22-a320-488c-92d5-41112example
```

### Source Credentials

Set your environment variables by sourcing the files before you run any terraform commands.

```
$ source ~/.azure/credentials
```

## Cloud Provider Resource Quotas

When deploying our cluster, you might experience some issues related to insufficient resource limits. Consequently, we recommend to verify your default limits [here](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits).

# Configure cluster

Set Azure as cloud provider.
```
make azure
```

The command above will download necessary [Terraform files](https://github.com/dcos/terraform-dcos/tree/master/azure) to `.deploy` folder.

Make updates if you need to (e.g. more private agents) to `.deploy/desired_cluster_profile`.
```
vi .deploy/desired_cluster_profile
dcos_version = "1.10.2"
num_of_masters = "1"
num_of_private_agents = "3"
num_of_public_agents = "1"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"
```

For more cluster setup tweaks check out [here](https://github.com/dcos/terraform-dcos/tree/master/azure).

# Cluster install

Follow steps from the main [readme](../README.md#install-cluster)

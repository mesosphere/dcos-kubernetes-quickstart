# AWS Cloud Provider

## Configure Credentials

### Configure your AWS ssh Keys

Set the private key that you will be you will be using to your ssh-agent and set public key in terraform. The default is `default`. You can find aws documentation that talks about this [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws).

When you have your key available, you can use ssh-add.

```bash
ssh-add ~/.ssh/path_to_you_key.pem
```

### Configure your IAM AWS Keys

You will need your AWS aws_access_key_id and aws_secret_access_key. If you dont have one yet, you can get them from the AWS documentation [here](
http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html). When you finally get them, you can install it in your home directory. The default location is `$HOME/.aws/credentials` on Linux and OS X, or `"%USERPROFILE%\.aws\credentials"` for Windows users.

Here is an example of the output when you're done:

```
$ cat ~/.aws/credentials
[default]
aws_access_key_id = ACHEHS71DG712w7EXAMPLE
aws_secret_access_key = /R8SHF+SHFJaerSKE83awf4ASyrF83sa471DHSEXAMPLE
```

The easiest way to get started on AWS is by setting environment variables with your access keys.

```
export AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY>
export AWS_SECRET_ACCESS_KEY=<YOUR SECRET KEY>
```

## Cloud Provider Resource Quotas

When deploying our cluster, you might experience some issues related to insufficient resource limits. Consequently, we recommend to verify your default limits [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-resource-limits.html).

# Configure cluster

Set AWS as cloud provider.
```
make aws
```
The command above will download necessary [Terraform files](https://github.com/dcos/terraform-dcos/tree/master/aws) to `.deploy` folder.

Make updates if you need to (e.g. more private agents) to `.deploy/desired_cluster_profile`, please do not change VMs to lover spec type, as then Kubernetes install will fail.
```
vi .deploy/desired_cluster_profile
dcos_version = "1.10.2"
num_of_masters = "1"
num_of_private_agents = "3"
num_of_public_agents = "1"
#
aws_region = "us-west-1"
aws_bootstrap_instance_type = "m3.large"
aws_master_instance_type = "m3.2xlarge"
aws_agent_instance_type = "m3.2xlarge"
aws_public_agent_instance_type = "m3.2xlarge"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"
```

For more cluster setup tweaks check out [here](https://github.com/dcos/terraform-dcos/tree/master/aws).

# Cluster install

Follow steps from the main [readme](../README.md#install-cluster)

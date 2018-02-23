# AWS

**WARNING**: When running this quickstart, you might experience some issues
with cloud resource limits. Please, verify your [quotas](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-resource-limits.html)
before proceeding.

## Instal AWS CLI

Make sure to have previously installed [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html).

## Setup access

First, you will need to [retrieve your AWS credentials](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
The default location is `$HOME/.aws/credentials` on Linux and OS X, or `"%USERPROFILE%\.aws\credentials"` for Windows users.

Before proceeding, we recommend you create a file with your AWS credentials,
exposed as (the commonly) recognized environment variables, so you can [`source`](http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x237.html)
it later, in between shell sessions:

```bash
$ cat << EOF > ~/.aws/my_credentials
export AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY>
export AWS_SECRET_ACCESS_KEY=<YOUR SECRET KEY>
EOF
```

Last, set-up SSH keys as detailed in [the official documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws).

Don't forget to add your new SSH private key to your session:

```bash
$ ssh-add ~/.ssh/path_to_your_new_key.pem
```

## Prepare infrastructure configuration

Make sure Terraform knows where to find your AWS credentials:

```bash
$ source ~/.aws/my_credentials
```

Now, let's generate the default infrastructure configuration:

```bash
$ make aws
```

This will output sane defaults to `.deploy/desired_cluster_profile`.
Now, edit said file and set `ssh_pub_key`, the public SSH key you will use to
log-in into your new VMs later.

**WARNING:** Please, do not set a smaller instance (VM) type on the risk of
failing to install Kubernetes.

```
custom_dcos_download_path = "https://downloads.dcos.io/dcos/EarlyAccess/1.11.0-rc4/dcos_generate_config.sh"
num_of_masters = "1"
num_of_private_agents = "3"
num_of_public_agents = "1"
#
aws_region = "us-west-1"
aws_bootstrap_instance_type = "m3.large"
aws_master_instance_type = "m3.2xlarge"
aws_agent_instance_type = "m3.2xlarge"
aws_public_agent_instance_type = "m3.2xlarge"
ssh_key_name = "default"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"
```

For more advanced scenarios, please check the [terraform-dcos documentation for AWS](https://github.com/dcos/terraform-dcos/tree/master/aws).

## Install

It's time to [bootstrap your Kubernetes cluster](../README.md#install).

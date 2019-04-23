cluster_name = "dcos-kubernetes"
cluster_name_random_string = true

dcos_version = "1.12.3"
dcos_security = "strict" # valid values are strict, permissive, disabled

num_of_masters = "1"
num_of_private_agents = "4"
num_of_public_agents = "1"

instance_os = "centos_7.5"
bootstrap_instance_type = "m5.large"
master_instance_type = "m5.2xlarge"
private_agent_instance_type = "m5.2xlarge"
public_agent_instance_type = "m5.2xlarge"

aws_region = "us-west-2"
# ssh_public_key_file = ""
# aws_key_name = "default" # uncomment to use an already defined AWS key
# admin_ips = "0.0.0.0/0" # uncomment to access master from any IP

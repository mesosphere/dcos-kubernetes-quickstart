cluster_name = "dcos-kubernetes"
cluster_name_random_string = true

dcos_version = "1.12.3"
dcos_security = "strict" # valid values are strict, permissive, disabled

num_of_masters = "1"
num_of_private_agents = "4"
num_of_public_agents = "1"

instance_os = "coreos_1855.5.0"
bootstrap_instance_type = "n1-standard-1"
master_instance_type = "n1-standard-8"
private_agent_instance_type = "n1-standard-8"
public_agent_instance_type = "n1-standard-8"

# admin_ips = "0.0.0.0/0" # uncomment to access master from any IP

gcp_project = "YOUR_GCP_PROJECT"
gcp_region = "us-central1"
ssh_public_key_file = "/PATH/YOUR_GCP_SSH_PUBLIC_KEY.pub"
#
# If you want to use GCP service account key instead of GCP SDK
# uncomment the line below and update it with the path to the key file
# gcp_credentials = "/PATH/YOUR_GCP_SERVICE_ACCOUNT_KEY.json"
#

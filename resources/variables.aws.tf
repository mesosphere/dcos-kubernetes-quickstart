variable "cluster_name" {
  description = "Name of the DC/OS cluster"
  default     = "dcos-kubernetes"
}

variable "cluster_name_random_string" {
  description = "Add a random string to the cluster name"
  default     = true
}

variable "ssh_public_key_file" {
  description = "Path to SSH public key. This is mandatory."
  default = ""
}

variable "aws_key_name" {
  description = "Specify the aws ssh key to use. We assume its already loaded in your SSH agent."
  default     = "default"
}

variable "aws_region" {
  description = "Region to be used"
  default = "us-west-2"
}

variable "admin_ips" {
  description = "List of CIDR admin IPs (space separated)"
  default     = ""
}

variable "dcos_version" {
  default     = "1.12.3"
  description = "specifies which dcos version instruction to use. Options: `1.9.0`, `1.8.8`, etc. _See [dcos_download_path](https://github.com/dcos/tf_dcos_core/blob/master/download-variables.tf) or [dcos_version](https://github.com/dcos/tf_dcos_core/tree/master/dcos-versions) tree for a full list._"
}

variable "dcos_security" {
  default     = "permissive"
  description = "[Enterprise DC/OS] set the security level of DC/OS. Default is strict. (recommended)"
}

variable "num_of_public_agents" {
  default = "0"
}

variable "num_of_private_agents" {
  default = "4"
}

variable "num_of_masters" {
  default     = "1"
  description = "set the num of master nodes (required with exhibitor_storage_backend set to aws_s3, azure, ZooKeeper)"
}

variable "instance_os" {
  description = "Operating system to use."
  default = "centos_7.5"
}

variable "bootstrap_instance_type" {
  description = "[BOOTSTRAP] Machine type"
  default     = "m5.large"
}

variable "master_instance_type" {
  description = "[MASTERS] Machine type"
  default     = "m5.2xlarge"
}

variable "private_agent_instance_type" {
  description = "[PRIVATE AGENTS] Machine type"
  default     = "m5.2xlarge"
}

variable "public_agent_instance_type" {
  description = "[PUBLIC AGENTS] Machine type"
  default     = "m5.2xlarge"
}

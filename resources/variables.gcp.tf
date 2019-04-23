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

variable "gcp_credentials" {
  description = "Either the path to or the contents of a service account key file in JSON format. You can manage key files using the Cloud Console."
  default = ""
}

variable "gcp_project" {
  description = "The default project to manage resources in. If another project is specified on a resource, it will take precedence."
  default = ""
}

variable "gcp_region" {
  description = "The default region to manage resources in. If another region is specified on a regional resource, it will take precedence."
  default = ""
}

variable "gcp_zone" {
  description = "The default zone to manage resources in. Generally, this zone should be within the default region you specified. If another zone is specified on a zonal resource, it will take precedence."
  default = ""
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

variable "bootstrap_machine_type" {
  description = "[BOOTSTRAP] Machine type"
  default     = "n1-standard-1"
}

variable "master_machine_type" {
  description = "[MASTERS] Machine type"
  default     = "n1-standard-8"
}

variable "private_agent_machine_type" {
  description = "[PRIVATE AGENTS] Machine type"
  default     = "n1-standard-8"
}

variable "public_agent_machine_type" {
  description = "[PUBLIC AGENTS] Machine type"
  default     = "n1-standard-8"
}

data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  dcos_admin_ips = "${split(" ", var.admin_ips == "" ? "${data.http.whatismyip.body}/32" : var.admin_ips)}"
}

provider "aws" {
  region = "${var.aws_region}"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name = "${var.cluster_name}"
  cluster_name_random_string = "${var.cluster_name_random_string}"

  num_masters = "${var.num_of_masters}"
  num_private_agents = "${var.num_of_private_agents}"
  num_public_agents = "${var.num_of_public_agents}"

  dcos_version = "${var.dcos_version}"
  dcos_variant = "open"
  dcos_security = "${var.dcos_security}"
  dcos_instance_os = "${var.instance_os}"

  bootstrap_instance_type = "${var.bootstrap_instance_type}"
  masters_instance_type = "${var.master_instance_type}"
  private_agents_instance_type = "${var.private_agent_instance_type}"
  public_agents_instance_type = "${var.public_agent_instance_type}"

  admin_ips = "${local.dcos_admin_ips}"
  aws_key_name = "${var.aws_key_name}"
  ssh_public_key_file = "${var.ssh_public_key_file}"

  public_agents_additional_ports = ["6443"]
}
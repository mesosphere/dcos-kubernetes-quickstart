data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  dcos_admin_ips = "${split(" ", var.admin_ips == "" ? "${data.http.whatismyip.body}/32" : var.admin_ips)}"
}

provider "google" {
  version = "~> 1.18.0"

  credentials = "${var.gcp_credentials}"
  project = "${var.gcp_project}"
  region = "${var.gcp_region}"
  zone = "${var.gcp_zone}"
}

module "dcos" {
  source  = "dcos-terraform/dcos/gcp"
  version = "~> 0.1.0"

  providers = {
    google = "google"
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

  bootstrap_machine_type = "${var.bootstrap_machine_type}"
  masters_machine_type = "${var.master_machine_type}"
  private_agents_machine_type = "${var.private_agent_machine_type}"
  public_agents_machine_type = "${var.public_agent_machine_type}"

  admin_ips = "${local.dcos_admin_ips}"
  ssh_public_key_file = "${var.ssh_public_key_file}"

  public_agents_additional_ports = ["6443"]

  dcos_resolvers = <<EOF
# YAML
  - 169.254.169.254
EOF
}
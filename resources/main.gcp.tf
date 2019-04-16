provider "google" {
  version = "~> 1.18.0"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

variable "dcos_install_mode" {
  description = "specifies which type of command to execute. Options: install or upgrade"
  default = "install"
}

module "dcos" {
  source = "dcos-terraform/dcos/gcp"
  version = "~> 0.1.0"

  cluster_name        = "__USERNAME__"
  ssh_public_key_file = "__GCP_SSH_PUBLIC_KEY_FILE__"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = "1"
  num_private_agents = "2"
  num_public_agents  = "1"

  dcos_version = "1.12.3"

  providers = {
    google = "google"
  }

  dcos_variant = "open"

  dcos_install_mode = "${var.dcos_install_mode}"
}

output "masters-ips" {
  value       = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value       = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}

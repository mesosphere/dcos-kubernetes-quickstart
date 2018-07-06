output "Master ELB Public IP" {
  value = "${azurerm_public_ip.master_load_balancer_public_ip.fqdn}"
}

output "Master Public IPs" {
  value = ["${azurerm_public_ip.master_public_ip.*.fqdn}"]
}

output "Public Agent ELB Public IP" {
  value = "${azurerm_public_ip.public_agent_load_balancer_public_ip.fqdn}"
}

output "Public Agent Public IPs" {
  value = ["${azurerm_public_ip.public_agent_public_ip.*.fqdn}"]
}

output "Master Load Balancer Public IP" {
  value = "${google_compute_forwarding_rule.external-master-forwarding-rule-http.ip_address}"
}

output "Master Public IPs" {
  value = ["${google_compute_instance.master.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "Public Agent Load Balancer Address" {
  value = "${google_compute_forwarding_rule.external-public-agent-forwarding-rule-http.ip_address}"
}

output "Public Agent Public IPs" {
  value = ["${google_compute_instance.public-agent.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

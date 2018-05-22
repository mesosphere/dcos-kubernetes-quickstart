output "Master ELB Public IP" {
  value = "${google_compute_forwarding_rule.external-master-forwarding-rule-http.ip_address}"
}

output "Master Public IPs" {
  value = ["${google_compute_instance.master.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

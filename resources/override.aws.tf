output "Master Load Balancer Public IP" {
  value = "${aws_elb.public-master-elb.dns_name}"
}

output "Master Public IPs" {
  value = ["${aws_instance.master.*.public_ip}"]
}

output "Public Agent Load Balancer Public IP" {
  value = "${aws_elb.public-agent-elb.dns_name}"
}

output "Public Agent Public IPs" {
  value = ["${aws_instance.public-agent.*.public_ip}"]
}

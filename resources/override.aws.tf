output "Master ELB Public IP" {
  value = "${aws_elb.public-master-elb.dns_name}"
}

output "Master Public IPs" {
  value = ["${aws_instance.master.*.public_ip}"]
}

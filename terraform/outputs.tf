output "elb_host_name" {
  value = "${aws_elb.drone.dns_name}"
}

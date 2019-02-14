resource "aws_security_group" "drone_elb" {
  description = "Drone Public Load balancer"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "drone" {
  name_prefix               = "drone"
  security_groups           = ["${aws_security_group.drone_elb.id}"]
  cross_zone_load_balancing = true
  subnets                   = ["${module.vpc.public_subnets}"]

  listener {
    instance_port     = 30080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:30080"
    interval            = 5
  }

  tags {
    env       = "${var.env}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_autoscaling_attachment" "drone" {
  autoscaling_group_name = "${module.eks.workers_asg_names[0]}"
  elb                    = "${aws_elb.drone.id}"
}

output "crontupisto" {
  value = "${module.eks.cluster_security_group_id}"
}

resource "aws_security_group_rule" "allow_lb" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.drone_elb.id}"

  security_group_id = "${module.eks.worker_security_group_id}"
}

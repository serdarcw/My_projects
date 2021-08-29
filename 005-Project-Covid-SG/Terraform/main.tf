provider "aws" {
  region = "us-east-2"
  profile = "clarusway_training"
}

locals {
  name              = "covid19_project"
  web_site_name     = "www.clarusway.us"
  zone_id           = "Z08348542LMKDSH94CCW6"
  certificate_arn   = "arn:aws:acm:us-east-2:046402772087:certificate/dae75cd6-8d82-420c-bed1-1ea132ec3d37"
  # Cloudfront needs the certificate issued in us-east-1 region. Unlike cloudfront, This certificate must be issued region in which that we create this ALB. 
  tags = {
    Name = local.name
  }
}

variable "key_pair" {
  default = "serdar_client"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "serdar-dynamic-ports" {
  default = [22,80,443]
}

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners           = ["amazon"]

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_security_group" "ec2_sec_group" {
  name        = "ec2_sec_group"
  description = "Allow SSH, HTTP inbound traffic"
  
  dynamic "ingress" {
    for_each = var.serdar-dynamic-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_ssh_http_https"
  }
}

resource "aws_security_group" "alb_sec_group" {
  name        = "alb_sec_group"
  description = "Allow SSH, HTTP inbound traffic"
  
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "HTTP from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_https_http"
  }
}

resource "aws_launch_template" "my_launch-teamplate" {
  name = "my_launch-teamplate"
  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  key_name = var.key_pair
  vpc_security_group_ids = [aws_security_group.ec2_sec_group.id]
  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
  user_data = filebase64("userdata.sh")
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sec_group.id]
  subnets            = ["subnet-4de77701","subnet-f693ba8c","subnet-160dfe7d"]
  ip_address_type    = "ipv4"
  enable_deletion_protection = false
  tags = local.tags
}

resource "aws_lb_target_group" "WebServerTargetGroup" {
  name     = "WebServerTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end1" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.WebServerTargetGroup.arn
  }
}


resource "aws_route53_record" "millisecond-record" {
  name = local.web_site_name
  type = "A"
  zone_id = local.zone_id

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                      = "web-asg"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 90
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = ["subnet-4de77701", "subnet-f693ba8c", "subnet-160dfe7d"]
  launch_template {
    id      = aws_launch_template.my_launch-teamplate.id
    version = "$Latest"
  }
  target_group_arns     = [aws_lb_target_group.WebServerTargetGroup.arn]
  tag {
    key                 = "name"
    value               = local.name
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }
}


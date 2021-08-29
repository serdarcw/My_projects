provider "aws" {
  region = local.region
  profile = "clarusway_training"
}

locals {
  name              = "phonebook_project"
  region            = "us-east-2"
  web_site_name     = "www.clarusway.us"
  zone_id           = "Z08348542LMKDSH94CCW6"
  certificate_arn_alb   = "arn:aws:acm:us-east-2:046402772087:certificate/dae75cd6-8d82-420c-bed1-1ea132ec3d37"
  certificate_arn_cloudfront = "arn:aws:acm:us-east-1:046402772087:certificate/f18e2185-58b5-47d2-a812-d1c5891ec26a"
  # Cloudfront needs the certificate issued in us-east-1 region. Unlike cloudfront, This certificate must be issued region in which that we create this ALB. 
  tags = {
    Name = local.name
  }
}

variable "key_pair" {
  default = "serdar_client"
}

variable "vpc_cidr" {
  default = "90.90.0.0/16"
}

variable "public_subnet_A_cidr" {
  default = "90.90.10.0/24"
}

variable "public_subnet_B_cidr" {
  default = "90.90.20.0/24"
}

variable "private_subnet_A_cidr" {
  default = "90.90.11.0/24"
}

variable "private_subnet_B_cidr" {
  default = "90.90.21.0/24"
}

variable "dbtype" {
  default = "db.t2.micro"
}

variable "dbusername" {
  default = "admin"
}

variable "dbpassword" {
  default = "Serdar_1"
}

variable "dbname" {
  default = "clarusway_phonebook"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "serdar-dynamic-ports" {
  default = [80,443]
}

variable "mydomainname" {
  default = "clarusway.us"
}

variable "sub_domain_name" {
  default = "www.clarusway.us"
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
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.serdar-dynamic-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      security_groups = [aws_security_group.alb_sec_group.id]
    }
  }
  ingress {
    description = "HTTP from anywhere"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_ssh_http_https"
  }
}

resource "aws_security_group" "alb_sec_group" {
  name        = "alb_sec_group"
  description = "Allow SSH, HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

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
    Name = "allow_https_http"
  }
}

resource "aws_security_group" "db_sec_group" {
  name        = "db_sec_group"
  description = "Allow mysql port inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Mysql from Ec2 sec group"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sec_group.id]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "db_sec_group"
  }
}

data "template_file" "userdata" {
  template = <<EOF
    #! /bin/bash
    yum update -y
    yum install python3 -y
    pip3 install flask
    pip3 install flask_mysql
    echo "${aws_db_instance.my_db_instance.address}" > home/ec2-user/dbserver.endpoint
    FOLDER="https://raw.githubusercontent.com/serdarcw/My_projects/master/003-phonebook-web-application/"
    curl -s --create-dirs -o "/home/ec2-user/templates/index.html" -L "$FOLDER"templates/index.html
    curl -s --create-dirs -o "/home/ec2-user/templates/add-update.html" -L "$FOLDER"templates/add-update.html
    curl -s --create-dirs -o "/home/ec2-user/templates/delete.html" -L "$FOLDER"templates/delete.html
    curl -s --create-dirs -o "/home/ec2-user/app.py" -L "$FOLDER"phonebook-app.py
    python3 /home/ec2-user/app.py
  EOF
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
  user_data = base64encode(data.template_file.userdata.rendered)
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sec_group.id]
  subnets            = [aws_subnet.main_public_subnet_A.id, aws_subnet.main_public_subnet_B.id]

  ip_address_type    = "ipv4"
  enable_deletion_protection = false
  tags = local.tags
}

resource "aws_lb_target_group" "WebServerTargetGroup" {
  name     = "WebServerTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}


resource "aws_lb_listener" "listener" {
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

resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn_alb

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.WebServerTargetGroup.arn
  }
}

resource "aws_cloudfront_distribution" "alb_distribution" {
  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = local.name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true

  aliases = [local.web_site_name]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.name

    forwarded_values {
      query_string = true
      headers = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.certificate_arn_cloudfront
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags
}

resource "aws_route53_record" "phonebook-record" {
  name = local.web_site_name
  type = "A"
  zone_id = local.zone_id

  alias {
    name                   = aws_cloudfront_distribution.alb_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                      = "web-asg"
  depends_on                = [aws_internet_gateway.main_igw]
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 90
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.main_private_subnet_A.id, aws_subnet.main_private_subnet_B.id]
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

resource "aws_db_subnet_group" "main_db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.main_private_subnet_A.id, aws_subnet.main_private_subnet_B.id]
  description = "Subnets available for the RDS DB Instance"

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "my_db_instance" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.20"
  identifier           = "my-db-instance"
  instance_class       = var.dbtype
  name                 = var.dbname
  username             = var.dbusername
  password             = var.dbpassword
  port                 = 3306
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true
  #parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  max_allocated_storage = 20
  db_subnet_group_name  = aws_db_subnet_group.main_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.db_sec_group.id]
  # maintenance_window = "Mon:00:00-Mon:03:00"
  # backup_window      = "04:00-06:00"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main_public_subnet_A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_A_cidr
  availability_zone = "${local.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "main_public_subnet_A"
  }
}

resource "aws_subnet" "main_public_subnet_B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_B_cidr
  availability_zone = "${local.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "main_public_subnet_B"
  }
}

resource "aws_subnet" "main_private_subnet_A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_A_cidr
  availability_zone = "${local.region}a"
  tags = {
    Name = "main_private_subnet_A"
  }
}

resource "aws_subnet" "main_private_subnet_B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_B_cidr
  availability_zone = "${local.region}b"

  tags = {
    Name = "main_private_subnet_B"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "main_public_RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main_public_RT"
  }
}

resource "aws_route_table" "main_private_RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat_gw.id
  }

  tags = {
    Name = "main_private_RT"
  }
}

resource "aws_route_table_association" "public_A_assos" {
  subnet_id      = aws_subnet.main_public_subnet_A.id
  route_table_id = aws_route_table.main_public_RT.id
}

resource "aws_route_table_association" "public_B_assos" {
  subnet_id      = aws_subnet.main_public_subnet_B.id
  route_table_id = aws_route_table.main_public_RT.id
}

resource "aws_route_table_association" "private_A_assos" {
  subnet_id      = aws_subnet.main_private_subnet_A.id
  route_table_id = aws_route_table.main_private_RT.id
}

resource "aws_route_table_association" "private_B_assos" {
  subnet_id      = aws_subnet.main_private_subnet_B.id
  route_table_id = aws_route_table.main_private_RT.id
}

resource "aws_eip" "main_eip" {
  vpc      = true
}

resource "aws_nat_gateway" "Nat_gw" {
  allocation_id = aws_eip.main_eip.id
  subnet_id     = aws_subnet.main_public_subnet_A.id
  depends_on    = [aws_internet_gateway.main_igw]

  tags = {
    Name = "NAT Gateway"
  }
}


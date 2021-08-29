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
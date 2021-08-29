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
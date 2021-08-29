provider "aws" {
  region = "us-east-2"
  profile = "clarusway_training"
}

locals {
  availability_zone = "${local.region}a"
  name              = "joinmeliora-ec2-volume-attachment"
  region            = "us-east-2"
  tags = {
    Environment = "dev"
    Name = "joinmeliora-ec2-volume-attachment"
  }
}

variable "serdar-dynamic-ports" {
  default = [22,80]
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

resource "aws_security_group" "my_sec_group1" {
  name        = "my_sec_group1"
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
  # ingress {
  #   description = "HTTPS from anywhere"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]

  # }
  # ingress {
  #   description = "HTTP from anywhere"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "SSH from anywhere"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]

  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_ssh_http"
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  key_name               = "serdar_client"
  #security_groups        = ["my_sec_group1"]
  vpc_security_group_ids = [ aws_security_group.my_sec_group1.id ]
  availability_zone      = local.availability_zone
  user_data              = file("userdata.sh")
  tags                   = local.tags
}

output "myec2_public_ip" {
  value = aws_instance.web.public_dns
}

output "myec2_private_ip" {
  value = aws_instance.web.private_dns
}
provider "aws" {
  region = "us-east-2"
  profile = "clarusway_training"
}

locals {
  name              = "millisecond_project"
  web_site_name     = "www.clarusway.us"
  zone_id           = "Z08348542LMKDSH94CCW6"
  certificate_arn   = "arn:aws:acm:us-east-2:046402772087:certificate/dae75cd6-8d82-420c-bed1-1ea132ec3d37"
  # Cloudfront needs the certificate issued in us-east-1 region. Unlike cloudfront, This certificate must be issued region in which that we create this ALB. 
  tags = {
    Name = local.name
  }
}

# values can be found in terraform.tfvars. even though you write here default value, terraform accept the values put into the terraform.tfvars. if you give different tfvars file name you have to indicate it with <terraform plan --var-file=serdar.tfvars> then <terraform apply --var-file=serdar.tfvars>
variable "key_pair" {
}

variable "instance_type" {
}

variable "serdar-dynamic-ports" {
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



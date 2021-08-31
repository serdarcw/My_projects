provider "aws" {
  region = local.region
  profile = local.aws_profile
}

locals {
  name              = "aws_capstone_project"
  aws_profile       = "clarusway_training"
  bucket_name       = "awscapstoneserdar"
  region            = "us-east-2"
  web_site_name     = "www.clarusway.us"
  zone_id           = "Z08348542LMKDSH94CCW6"
  certificate_arn_alb   = "XXXXXXXXXXXXXXXXXXXXXXX"
  certificate_arn_cloudfront = "XXXXXXXXXXXXXXXXXXXXXXXX"
  # write your certficate arn for https secure connection used by Cloudfront. Be careful!!! Even though you create this stack any region except us-east-1, Cloudfront needs the certificate issued in us-east-1 region. Thts why, if you create this stack in us-east-1, you can use your certificate issued in this region, but if you create this stack in different region, you have to use a certificate isuued in us-east-1. 
  tags = {
    Name = local.name
  }
}
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
  certificate_arn_alb   = "arn:aws:acm:us-east-2:046402772087:certificate/dae75cd6-8d82-420c-bed1-1ea132ec3d37"
  certificate_arn_cloudfront = "arn:aws:acm:us-east-1:046402772087:certificate/f18e2185-58b5-47d2-a812-d1c5891ec26a"
  # Cloudfront needs the certificate issued in us-east-1 region. Unlike cloudfront, This certificate must be issued region in which we create this ALB. 
  tags = {
    Name = local.name
  }
}
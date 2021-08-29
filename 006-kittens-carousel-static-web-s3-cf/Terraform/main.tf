provider "aws" {
  region = "us-east-2"
  profile = "clarusway_training"
}
# Guzel bir makale ---> https://www.alexhyett.com/terraform-s3-static-website-hosting/
locals {
  name              = "kittens carousel"
  region            = "us-east-2"
  web_site_name     = "www.clarusway.us"
  zone_id           = "Z08348542LMKDSH94CCW6"
  certificate_arn   = "arn:aws:acm:us-east-1:046402772087:certificate/f18e2185-58b5-47d2-a812-d1c5891ec26a"
  tags = {
    Name = local.name
  }
}

resource "aws_s3_bucket_policy" "kittens_bucket_policy" {
  bucket = aws_s3_bucket.kittens_bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "PublicReadforKittensBucket"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.kittens_bucket.arn,
          "${aws_s3_bucket.kittens_bucket.arn}/*",
        ]
      }
    ]
  })
}


resource "aws_s3_bucket" "kittens_bucket" {
  bucket = local.web_site_name
  acl    = "public-read"
  website {
    index_document = "index.html"
  }
  tags = local.tags
}


resource "aws_route53_record" "kittens-record" {
  name = local.web_site_name
  type = "A"
  zone_id = local.zone_id

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

# Cloudfront distribution for main s3 site.
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.kittens_bucket.bucket_regional_domain_name
    origin_id   = local.name

    # custom_origin_config {
    #   http_port              = 80
    #   https_port             = 443
    #   origin_protocol_policy = "http-only"
    #   origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [local.web_site_name]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.name

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
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
    acm_certificate_arn      = local.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags
}

output "cloudfront.dns" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "S3 endpoint" {
  value = aws_s3_bucket.kittens_bucket.website_endpoint
}

output "Route53" {
  value = aws_route53_record.kittens-record.alias
}


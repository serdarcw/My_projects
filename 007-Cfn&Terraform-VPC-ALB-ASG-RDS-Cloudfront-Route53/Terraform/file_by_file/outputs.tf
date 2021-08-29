output "cloudfront_DNS" {
  value = aws_cloudfront_distribution.alb_distribution.domain_name
}

output "ALB_DNS" {
  value = aws_lb.alb.dns_name
}

output "website_address" {
  value = aws_route53_record.phonebook-record.id
}


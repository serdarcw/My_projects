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
resource "aws_route53_record" "millisecond-record" {
  name = local.web_site_name
  type = "A"
  zone_id = local.zone_id

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
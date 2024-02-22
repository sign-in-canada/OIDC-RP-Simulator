resource "aws_route53_zone" "keycloak" {
  name = var.domain
  tags = local.common_tags
}

resource "aws_route53_record" "keycloak_A" {
  zone_id = aws_route53_zone.keycloak.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.keycloak.dns_name
    zone_id                = aws_lb.keycloak.zone_id
    evaluate_target_health = false
  }
}

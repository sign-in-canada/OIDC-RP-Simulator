resource "aws_lb" "keycloak" {
  name               = "keycloak-${var.env}"
  internal           = false
  load_balancer_type = "application"

  drop_invalid_header_fields = true
  enable_deletion_protection = true

  security_groups = [
    aws_security_group.keycloak_lb.id
  ]
  subnets = module.keycloak_vpc.public_subnet_ids

  tags = local.common_tags
}

resource "random_string" "alb_tg_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "aws_lb_target_group" "keycloak" {
  name                 = "keycloak-tg-${random_string.alb_tg_suffix.result}"
  port                 = 8080
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = 30
  vpc_id               = module.keycloak_vpc.vpc_id

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/"
    matcher  = "200-399"
  }

  stickiness {
    type = "lb_cookie"
  }

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      stickiness[0].cookie_name
    ]
  }
}

resource "aws_lb_listener" "keycloak" {
  load_balancer_arn = aws_lb.keycloak.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.keycloak.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.keycloak.arn
  }

  depends_on = [
    aws_acm_certificate_validation.keycloak,
    aws_route53_record.keycloak_validation,
  ]

  tags = local.common_tags
}

resource "aws_lb_listener" "keycloak_http_redirect" {
  load_balancer_arn = aws_lb.keycloak.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.common_tags
}

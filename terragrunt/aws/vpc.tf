module "keycloak_vpc" {
  source = "github.com/cds-snc/terraform-modules//vpc?ref=v9.1.0"
  name   = "keycloak-${var.env}"

  enable_flow_log                  = true
  availability_zones               = 2
  cidrsubnet_newbits               = 8
  single_nat_gateway               = true
  allow_https_request_out          = true
  allow_https_request_out_response = true
  allow_https_request_in           = true
  allow_https_request_in_response  = true

  billing_tag_value = var.billing_code
}

#
# Security groups
#

# ECS
resource "aws_security_group" "keycloak_ecs" {
  description = "NSG for Keycloak ECS Tasks"
  name        = "keycloak_ecs"
  vpc_id      = module.keycloak_vpc.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "keycloak_ecs_egress_internet" {
  description       = "Egress from Keycloak ECS task to internet (HTTPS)"
  type              = "egress"
  to_port           = 443
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.keycloak_ecs.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "keycloak_ecs_ingress_lb" {
  description              = "Ingress from load balancer to Keycloak ECS task"
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.keycloak_ecs.id
  source_security_group_id = aws_security_group.keycloak_lb.id
}

# Load balancer
resource "aws_security_group" "keycloak_lb" {
  name        = "keycloak_lb"
  description = "NSG for Keycloak load balancer"
  vpc_id      = module.keycloak_vpc.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "keycloak_lb_ingress_internet_http" {
  description       = "Ingress from internet to load balancer (HTTP)"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.keycloak_lb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "keycloak_lb_ingress_internet_https" {
  description       = "Ingress from internet to load balancer (HTTPS)"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.keycloak_lb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "keycloak_lb_egress_ecs" {
  description              = "Egress from load balancer to Keycloak ECS task"
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.keycloak_lb.id
  source_security_group_id = aws_security_group.keycloak_ecs.id
}

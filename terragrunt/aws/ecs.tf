locals {
  container_env = [
    {
      "name"  = "AWS_REGION",
      "value" = "ca-central-1"
    },
    {
      "name"  = "KC_PROXY",
      "value" = "edge"
    },
    {
      "name"  = "KC_HOSTNAME_STRICT",
      "value" = "false"
    },
    {
      "name"  = "KC_HOSTNAME",
      "value" = var.domain
    },
    {
      "name"  = "KC_HEALTH_ENABLED",
      "value" = "true"
    },
    {
      "name"  = "KEYCLOAK_LOGLEVEL",
      "value" = "DEBUG"
    },
    {
      "name"  = "PROXY_ADDRESS_FORWARDING",
      "value" = "true"
    }
  ]
  container_secrets = [
    {
      "name"      = "KEYCLOAK_ADMIN"
      "valueFrom" = aws_ssm_parameter.keycloak_admin.arn
    },
    {
      "name"      = "KEYCLOAK_ADMIN_PASSWORD"
      "valueFrom" = aws_ssm_parameter.keycloak_admin_password.arn
    },
    {
      "name"      = "KC_DB_URL"
      "valueFrom" = aws_ssm_parameter.keycloak_database_url.arn
    },
    {
      "name"      = "KC_DB_USERNAME"
      "valueFrom" = aws_ssm_parameter.keycloak_database_username.arn
    },
    {
      "name"      = "KC_DB_PASSWORD"
      "valueFrom" = aws_ssm_parameter.keycloak_database_password.arn
    },
  ]
}

module "keycloak_ecs" {
  source = "github.com/cds-snc/terraform-modules//ecs?ref=v9.2.2"

  cluster_name = "keycloak"
  service_name = "keycloak"
  task_cpu     = 1024
  task_memory  = 2048

  enable_execute_command = true

  # Scaling
  enable_autoscaling       = true
  desired_count            = 1
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 2

  # Task definition
  container_image                     = "${aws_ecr_repository.keycloak.repository_url}:latest"
  container_host_port                 = 8080
  container_port                      = 8080
  container_environment               = local.container_env
  container_secrets                   = local.container_secrets
  container_read_only_root_filesystem = false
  task_exec_role_policy_documents = [
    data.aws_iam_policy_document.ecs_task_ssm_parameters.json
  ]
  task_role_policy_documents = [
    data.aws_iam_policy_document.ecs_task_create_tunnel.json
  ]

  # Networking
  lb_target_group_arn = aws_lb_target_group.keycloak.arn
  subnet_ids          = module.keycloak_vpc.private_subnet_ids
  security_group_ids  = [aws_security_group.keycloak_ecs.id]

  billing_tag_value = var.billing_code
}

# #
# # IAM policies
# #
# data "aws_iam_policy_document" "ecs_task_ssm_parameters" {
#   statement {
#     sid    = "GetSSMParameters"
#     effect = "Allow"
#     actions = [
#       "ssm:GetParameter",
#       "ssm:GetParameters",
#     ]
#     resources = [
#       aws_ssm_parameter.keycloak_admin.arn,
#       aws_ssm_parameter.keycloak_admin_password.arn,
#       aws_ssm_parameter.keycloak_database_url.arn,
#       aws_ssm_parameter.keycloak_database_username.arn,
#       aws_ssm_parameter.keycloak_database_password.arn,
#     ]
#   }
# }

# data "aws_iam_policy_document" "ecs_task_create_tunnel" {
#   statement {
#     sid    = "CreateSSMTunnel"
#     effect = "Allow"
#     actions = [
#       "ssmmessages:CreateControlChannel",
#       "ssmmessages:CreateDataChannel",
#       "ssmmessages:OpenControlChannel",
#       "ssmmessages:OpenDataChannel"
#     ]
#     resources = ["*"]
#   }
# }

# #
# # SSM Parameters
# #
# resource "aws_ssm_parameter" "keycloak_admin" {
#   name  = "keycloak_admin"
#   type  = "SecureString"
#   value = var.keycloak_admin
#   tags  = local.common_tags
# }

# resource "aws_ssm_parameter" "keycloak_admin_password" {
#   name  = "keycloak_admin_password"
#   type  = "SecureString"
#   value = var.keycloak_admin_password
#   tags  = local.common_tags
# }

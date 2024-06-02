resource "aws_service_discovery_private_dns_namespace" "pt-notification" {
  name        = "pt-notification.local"
  description = "Private DNS namespace for the pt-notification"
  vpc         = "vpc-0ff132c5791c89f58"
}

resource "aws_service_discovery_service" "notification_service" {
  name = "notification-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.pt-notification.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "email_service" {
  name = "email-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.pt-notification.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_appmesh_mesh" "pt-notification" {
  name = "pt-notification"
}

resource "aws_appmesh_virtual_node" "notification_node" {
  mesh_name = aws_appmesh_mesh.pt-notification.name
  name      = "notification-node"

  spec {
    listener {
      port_mapping {
        port     = 3000
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = aws_service_discovery_private_dns_namespace.pt-notification.name
        service_name   = aws_service_discovery_service.notification_service.name
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "email_node" {
  mesh_name = aws_appmesh_mesh.pt-notification.name
  name      = "email-node"

  spec {
    listener {
      port_mapping {
        port     = 3000
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        namespace_name = aws_service_discovery_private_dns_namespace.pt-notification.name
        service_name   = aws_service_discovery_service.email_service.name
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "notification_service" {
  mesh_name = aws_appmesh_mesh.pt-notification.name
  name      = "notification-service.pt-notification.local"

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.notification_node.name
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "email_service" {
  mesh_name = aws_appmesh_mesh.pt-notification.name
  name      = "email-service.pt-notification.local"

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.email_node.name
      }
    }
  }
}


# # ECS Task Definition for Notification Service
# resource "aws_ecs_task_definition" "notification_task" {
#   family                   = "notification-service-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "1024"
#   memory                   = "2048"

#   container_definitions = jsonencode([
#     {
#       name  = "pt-notification-service"
#       image = "785008697030.dkr.ecr.us-west-1.amazonaws.com/pt-notification-service:latest"
#       essential = true

#       portMappings = [
#         {
#           containerPort = 3000
#           hostPort      = 3000
#         }
#       ]

#       environment = [
#         {
#           name  = "ENV_VAR_NAME"
#           value = "value"
#         }
#       ]

#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = "/ecs/pt-notification-service"
#           "awslogs-region"        = "us-west-1"
#           "awslogs-stream-prefix" = "ecs"
#         }
#       }
#     }
#   ])

#   execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
#   task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
# }

# # ECS Service for Notification Service
# resource "aws_ecs_service" "notification_service" {
#   name            = "notification-service"
#   cluster         = aws_ecs_cluster.notification-cluster.id
#   task_definition = aws_ecs_task_definition.notification_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = ["subnet-0e60438ba826ed1b4", "subnet-0f6ecd789b43a04c8"]
#     security_groups  = ["sg-0c87fd695f98bc8af"]
#     assign_public_ip = true
#   }

#   service_registries {
#     registry_arn = aws_servicediscovery_service.notification_service.arn
#   }
# }

# # ECS Task Definition for Email Service
# resource "aws_ecs_task_definition" "email_task" {
#   family                   = "email-service-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "1024"
#   memory                   = "2048"

#   container_definitions = jsonencode([
#     {
#       name  = "pt-email-service"
#       image = "785008697030.dkr.ecr.us-west-1.amazonaws.com/pt-email-service:latest"
#       essential = true

#       portMappings = [
#         {
#           containerPort = 3000
#           hostPort      = 3000
#         }
#       ]

#       environment = [
#         {
#           name  = "ENV_VAR_NAME"
#           value = "value"
#         }
#       ]

#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = "/ecs/pt-email-service"
#           "awslogs-region"        = "us-west-1"
#           "awslogs-stream-prefix" = "ecs"
#         }
#       }
#     }
#   ])

#   execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
#   task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
# }

# # ECS Service for Email Service
# resource "aws_ecs_service" "email_service" {
#   name            = "email-service"
#   cluster         = aws_ecs_cluster.notification-cluster.id
#   task_definition = aws_ecs_task_definition.email_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = ["subnet-0e60438ba826ed1b4", "subnet-0f6ecd789b43a04c8"]
#     security_groups  = ["sg-0c87fd695f98bc8af"]
#     assign_public_ip = true
#   }

#   service_registries {
#     registry_arn = aws_servicediscovery_service.email_service.arn
#   }
# }

resource "aws_sqs_queue" "notification_queue" {
  name = "notification-queue"
}

resource "aws_iam_role_policy" "ecs_sqs_policy" {
  name = "ecs-sqs-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Effect = "Allow",
        Resource = aws_sqs_queue.notification_queue.arn
      }
    ]
  })
}


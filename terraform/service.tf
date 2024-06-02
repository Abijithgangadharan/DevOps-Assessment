# ECS Task Definition
resource "aws_ecs_task_definition" "notification_task" {
  family                   = "notification-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"  
  memory                   = "2048" 

  container_definitions = jsonencode([
    {
      name  = "pt-notification-service"
      image = "785008697030.dkr.ecr.us-west-1.amazonaws.com/pt-notification-service:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]

      environment = [
        {
          name  = "ENV_VAR_NAME"
          value = "value"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/pt-notification-service"
          "awslogs-region"        = "us-west-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      


    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

# ECS Service
resource "aws_ecs_service" "notification_service" {
  name            = "notification-service"
  cluster         = aws_ecs_cluster.notification-cluster.id
  task_definition = aws_ecs_task_definition.notification_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0e60438ba826ed1b4", "subnet-0f6ecd789b43a04c8"] 
    security_groups  = ["sg-0c87fd695f98bc8af"]     
    assign_public_ip = true
  }
  service_registries {
    registry_arn = aws_service_discovery_service.notification_service.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.notification_tg.arn
    container_name   = "pt-notification-service"
    container_port   = 3000
  }
}

# ALB Target Group
resource "aws_alb_target_group" "notification_tg" {
  name     = "notification-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "vpc-0ff132c5791c89f58"
  target_type = "ip" 

  health_check {
    path                = "/api"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB Listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.notification_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.notification_tg.arn
  }
}

# ALB
resource "aws_alb" "notification_lb" {
  name            = "notification-lb"
  internal        = false
  load_balancer_type = "application"
  security_groups = ["sg-0c87fd695f98bc8af"] 
  subnets         = ["subnet-0e60438ba826ed1b4", "subnet-0f6ecd789b43a04c8"]  
}


# ECS Task Definition
resource "aws_ecs_task_definition" "email_task" {
  family                   = "email-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"  
  memory                   = "2048" 

  container_definitions = jsonencode([
    {
      name  = "pt-email-service"
      image = "785008697030.dkr.ecr.us-west-1.amazonaws.com/pt-email-service:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]

      environment = [
        {
          name  = "ENV_VAR_NAME"
          value = "value"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/pt-email-service"
          "awslogs-region"        = "us-west-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

# ECS Service
resource "aws_ecs_service" "email_service" {
  name            = "email-service"
  cluster         = aws_ecs_cluster.notification-cluster.id
  task_definition = aws_ecs_task_definition.email_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0e60438ba826ed1b4", "subnet-0f6ecd789b43a04c8"] 
    security_groups  = ["sg-0c87fd695f98bc8af"]     
    assign_public_ip = true
  }
  service_registries {
    registry_arn = aws_service_discovery_service.email_service.arn
  }

#   load_balancer {
#     target_group_arn = aws_alb_target_group.notification_tg.arn
#     container_name   = "pt-email-service"
#     container_port   = 3000
#   }
 }

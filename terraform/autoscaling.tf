# ECS API Service Auto Scaling Target
resource "aws_appautoscaling_target" "notification_api_service_scaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.notification-cluster.name}/${aws_ecs_service.notification_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 2  # Minimum number of tasks
  max_capacity       = 10 # Maximum number of tasks
}

# ECS API Service Auto Scaling Policy
resource "aws_appautoscaling_policy" "notification_api_service_scaling_policy" {
  name                   = "notification-api-service-cpu-scaling-policy"
  resource_id            = aws_appautoscaling_target.notification_api_service_scaling_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.notification_api_service_scaling_target.scalable_dimension
  service_namespace      = aws_appautoscaling_target.notification_api_service_scaling_target.service_namespace

  policy_type            = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value          = 70  # Target CPU utilization percentage
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown     = 300  # Cooldown period for scale-in actions (in seconds)
    scale_out_cooldown    = 300  # Cooldown period for scale-out actions (in seconds)
  }
}

# ECS Email Service Auto Scaling Target
resource "aws_appautoscaling_target" "email_service_scaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.notification-cluster.name}/${aws_ecs_service.email_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 2  # Minimum number of tasks
  max_capacity       = 10 # Maximum number of tasks
}

# ECS Email Service Auto Scaling Policy
resource "aws_appautoscaling_policy" "email_service_scaling_policy" {
  name                   = "email-service-cpu-scaling-policy"
  resource_id            = aws_appautoscaling_target.email_service_scaling_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.email_service_scaling_target.scalable_dimension
  service_namespace      = aws_appautoscaling_target.email_service_scaling_target.service_namespace

  policy_type            = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    target_value          = 70  # Target CPU utilization percentage
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown     = 300  # Cooldown period for scale-in actions (in seconds)
    scale_out_cooldown    = 300  # Cooldown period for scale-out actions (in seconds)
  }
}

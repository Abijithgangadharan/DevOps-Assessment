resource "aws_kms_key" "pt-notification-service" {
description             = "pt-notication-service"
deletion_window_in_days = 7
}

# resource "aws_cloudwatch_log_group" "pt-notication-service" {
#   name = "pt-notication-service"
# }

resource "aws_ecs_cluster" "notification-cluster" {
name = "notification-cluster"

configuration {
  execute_command_configuration {
    kms_key_id = aws_kms_key.pt-notification-service.arn
    logging    = "OVERRIDE"

    log_configuration {
      cloud_watch_encryption_enabled = true
      cloud_watch_log_group_name     = aws_cloudwatch_log_group.pt-notification-service.name
    }
  }
}
}

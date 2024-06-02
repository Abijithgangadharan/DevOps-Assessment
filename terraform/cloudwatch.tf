# CloudWatch Log Group for ECS Task Logs
resource "aws_cloudwatch_log_group" "pt-notification-service" {
 name              = "/ecs/pt-notification-service"  # Adjust the log group name as needed
 retention_in_days = 7  # Adjust retention period as needed
}

# CloudWatch Log Stream for Notification API Service
resource "aws_cloudwatch_log_stream" "notification_api_log_stream" {
 name           = "notification-api"
 log_group_name = aws_cloudwatch_log_group.pt-notification-service.name
}

# CloudWatch Log Stream for Email Sender Service
resource "aws_cloudwatch_log_stream" "email_sender_log_stream" {
 name           = "email-sender"
 log_group_name = aws_cloudwatch_log_group.pt-notification-service.name
}

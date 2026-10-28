output "mysql_secret_arn" {
  description = "ARN of the MySQL Secrets Manager secret container."
  value       = aws_secretsmanager_secret.mysql.arn
}

output "mysql_secret_name" {
  description = "Name of the MySQL Secrets Manager secret."
  value       = aws_secretsmanager_secret.mysql.name
}

output "rabbitmq_secret_arn" {
  description = "ARN of the RabbitMQ Secrets Manager secret container."
  value       = aws_secretsmanager_secret.rabbitmq.arn
}

output "rabbitmq_secret_name" {
  description = "Name of the RabbitMQ Secrets Manager secret."
  value       = aws_secretsmanager_secret.rabbitmq.name
}

output "secret_arns" {
  description = "List of all SUM Store Secrets Manager secret container ARNs."
  value = [
    aws_secretsmanager_secret.mysql.arn,
    aws_secretsmanager_secret.rabbitmq.arn,
  ]
}

resource "aws_secretsmanager_secret" "mysql" {
  name                    = "sumstore/mysql"
  description             = "SUM Store MySQL authoritative secret container (populated out-of-band via bootstrap)"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret" "rabbitmq" {
  name                    = "sumstore/rabbitmq"
  description             = "SUM Store RabbitMQ authoritative secret container (populated out-of-band via bootstrap)"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret" "mysql" {
  name                    = "${var.secret_prefix}/mysql"
  description             = "SUM Store MySQL authoritative secret container (populated out-of-band via bootstrap)"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret" "mongodb" {
  name                    = "${var.secret_prefix}/mongodb"
  description             = "SUM Store MongoDB authoritative secret container (populated out-of-band via bootstrap)"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret" "redis" {
  name                    = "${var.secret_prefix}/redis"
  description             = "SUM Store Redis authoritative secret container (populated out-of-band via bootstrap)"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret" "rabbitmq" {
  name                    = "${var.secret_prefix}/rabbitmq"
  description             = "SUM Store RabbitMQ authoritative secret container (populated out-of-band via bootstrap)"
  recovery_window_in_days = 0
  tags                    = var.tags
}

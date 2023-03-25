resource "random_string" "secret_name" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = random_string.secret_name.result
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  secret_string = jsonencode({
    "username" : var.rds_credentials.username,
    "password" : var.rds_credentials.password,
    "engine" : aws_db_instance.main.engine,
    "host" : aws_db_instance.main.address,
    "port" : aws_db_instance.main.port
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "Main DB Subnet Group"
  }
}

resource "aws_db_instance" "main" {
  db_name    = var.db_name
  identifier = "terraform-main"

  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = var.rds_credentials.username
  password             = var.rds_credentials.password
  db_subnet_group_name = aws_db_subnet_group.main.name
  parameter_group_name = "default.mysql5.7"
  allocated_storage    = 10
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.main.id]
}

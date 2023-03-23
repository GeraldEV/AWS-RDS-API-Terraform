# AWS Elastic Container Service (ECS)

resource "aws_ecs_cluster" "main" {
  name = var.project_name

  tags = {
    Name = "${var.project_name} ECS Cluster"
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.project_name}LogGroup"

  tags = {
    Name = "${var.project_name} Log Group"
  }
}

resource "aws_ecs_task_definition" "service" {
  family = "tf-service"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.service_specs.memory
  cpu                      = var.service_specs.cpu
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.execution_role.arn

  container_definitions = jsonencode([{
    name      = var.service_specs.name
    image     = var.service_specs.image
    essential = true

    portMappings = [{
      containerPort = var.ingress_specs.port
      hostPort      = var.ingress_specs.port
    }]

    environment = [
      {
        "name" : "SECRET_NAME",
        "value" = var.secret_name
      },
      {
        "name" : "SECRET_REGION",
        "value" = var.region
      },
      {
        "name" : "DB_NAME",
        "value" = var.db_name
      }
    ]

    logConfiguration = {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : aws_cloudwatch_log_group.log_group.name,
        "awslogs-region" : var.region,
        "awslogs-stream-prefix" : "ecs"
      }
    }
  }])

  tags = {
    Name = "${var.project_name} TaskDef"
  }
}

resource "aws_ecs_service" "aws-ecs-service" {
  depends_on = [aws_db_instance.main]

  name                 = "ecs-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.service.family
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.public_a.id]
    assign_public_ip = true
    security_groups = [
      aws_security_group.main.id
    ]
  }
}

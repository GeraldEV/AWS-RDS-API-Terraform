# Input Variables

variable "project_name" {
  description = "Project Name"

  type    = string
  default = "Artists"
}

variable "region" {
  description = "Region for deployment, must match the region in provider.tf"

  type    = string
  default = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"

  type    = string
  default = "10.1.0.0/16"
}

variable "subnet_cidr_public_a" {
  description = "CIDR block for the Public A subnet"

  type    = string
  default = "10.1.0.0/25"
}

variable "subnet_cidr_public_b" {
  description = "CIDR block for the Public B subnet"

  type    = string
  default = "10.1.0.128/25"
}

variable "subnet_cidr_private_a" {
  description = "CIDR block for the Private A subnet"

  type    = string
  default = "10.1.1.0/25"
}

variable "subnet_cidr_private_b" {
  description = "CIDR block for the Private B subnet"

  type    = string
  default = "10.1.1.128/25"
}

variable "my_network" {
  description = "IPv4 CIDR for your network to allow traffic to deployed services"

  type     = string
  nullable = false
}

variable "ingress_specs" {
  description = "Port and Protocol for Ingress"

  type = object({
    port     = number
    protocol = string
  })

  default = {
    port     = 80
    protocol = "tcp"
  }
}

variable "service_specs" {
  description = "Sepcification for ECS"

  type = object({
    name  = string
    image = string

    memory = string
    cpu    = string
  })

  default = {
    name   = "ArtistsAPI"
    image  = null
    memory = "512"
    cpu    = "256"
  }

  nullable = false
}

variable "secret_name" {
  description = "Secret name in secret manager"

  type     = string
  nullable = false
}

variable "db_name" {
  description = "Named database to be created"

  type     = string
  nullable = false
}

variable "rds_credentials" {
  description = "Credentials to set on the database"

  type = object({
    username = string
    password = string
  })

  default = {
    username = "admin"
    password = "superlongsecurepassword"
  }

  nullable  = false
  sensitive = true
}


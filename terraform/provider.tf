provider "aws" {
  region = var.region

  default_tags {
    tags = {
      terraform = "true",
      project   = var.project_name
    }
  }
}


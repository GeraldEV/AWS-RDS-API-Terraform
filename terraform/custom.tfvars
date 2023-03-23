my_network = "<your network IP address here>"

secret_name = "my_secret"

db_name = "artists"

service_specs = {
  name   = "ArtistsAPI"
  image  = "<link to your ECR image>"
  memory = "512"
  cpu    = "256"
}

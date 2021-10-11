data "terraform_remote_state" "bootstrap" {
  backend = "local"
  config = {
    path = "../03-bootstrap/terraform.tfstate"
  }
}
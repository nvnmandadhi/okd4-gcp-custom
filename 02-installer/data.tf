data "terraform_remote_state" "initialize" {
  backend = "local"
  config = {
    path = "../01-initialize/terraform.tfstate"
  }
}
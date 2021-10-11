data "terraform_remote_state" "initialize" {
  backend = "local"
  config = {
    path = "../01-initialize/terraform.tfstate"
  }
}

data "terraform_remote_state" "installer" {
  backend = "local"
  config = {
    path = "../02-installer/terraform.tfstate"
  }
}
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

data "terraform_remote_state" "bootstrap" {
  backend = "local"
  config = {
    path = "../03-bootstrap/terraform.tfstate"
  }
}

data "terraform_remote_state" "machines" {
  backend = "local"
  config = {
    path = "../04-machines/terraform.tfstate"
  }
}
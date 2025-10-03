terraform {
  backend "s3" {
    bucket         = "store-infra-state-eem"
    key            = "terraform.tfstate"
    region         = "ap-southeast-7"
    encrypt        = true
  }
}
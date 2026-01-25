terraform {
  backend "s3" {
    bucket         = "generate-infra-terraform-state-bucket" 
    key            = "infra/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}
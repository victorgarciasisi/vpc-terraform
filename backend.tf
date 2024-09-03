
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-dev-states"
    key            = "eu-west-1/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
  }
}

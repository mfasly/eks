terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "myterraformstatestratos"
    key            = "statefiles/stratos/terraform.tfstate"
    region         = "us-east-1"
    #dynamodb_table = "state_lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.56.0"
    }
  }
}
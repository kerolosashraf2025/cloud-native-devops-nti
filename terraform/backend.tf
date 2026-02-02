terraform {
  backend "s3" {
    bucket         = "cloud-native-devops-nti-tf-state"
    key            = "infra/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

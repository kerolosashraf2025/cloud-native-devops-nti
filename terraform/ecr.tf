resource "aws_ecr_repository" "sample_app" {
  name                 = "cloud-native-sample-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.sample_app.repository_url
}

# ==========================================================
# ECR Repo for Sample App (Voting App)
# ==========================================================
resource "aws_ecr_repository" "sample_app" {
  name                 = "cloud-native-sample-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# ==========================================================
# ECR Repo for Mongo Writer Microservice
# ==========================================================
resource "aws_ecr_repository" "mongo_writer" {
  name                 = "cloud-native-mongo-writer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# ==========================================================
# Outputs
# ==========================================================
output "ecr_sample_app_repository_url" {
  value = aws_ecr_repository.sample_app.repository_url
}

output "ecr_mongo_writer_repository_url" {
  value = aws_ecr_repository.mongo_writer.repository_url
}

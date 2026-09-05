resource "aws_ecr_repository" "ecr_lwa" {
  name                 = "ecr-${local.name_suffix}"
  image_tag_mutability = "IMMUTABLE"
  tags = {
    Name = "ecr-${local.name_suffix}"
  }
}

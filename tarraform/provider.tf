variable "aws_access_key" {
  type = string
}
variable "aws_secret_key" {
  type = string
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "ap-northeast-2"
}
//terraform apply -var aws_access_key=$AWS_ADMIN_ACCESS_KEY -var aws_secret_key=$AWS_ADMIN_SECRET_KEY
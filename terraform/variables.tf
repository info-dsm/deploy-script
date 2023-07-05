variable "aws_access_key" {
  description = "AWS IAM access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS IAM access key"
  type        = string
}

variable "aws_region" {
  description = "Geographical zone for the AWS"
  type        = string
}

variable "instance_type" {
  description = "Instance type for AWS ec2 instance."
  type        = string
}

# Cloudflare variables
variable "cloudflare_zone" {
  description = "Domain used to expose the GCP VM instance to the Internet"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for your domain"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Email address for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_token" {
  description = "Cloudflare API token created at https://dash.cloudflare.com/profile/api-tokens"
  type        = string
}

variable "infodsm_key_name" {
  description = "ssh key name"
  type        = string
}

variable "aws_instance_ami_id" {
  description = "aws machine image"
  type        = string
}

variable "private_key_path" {
  description = "private key path"
  type        = string
}

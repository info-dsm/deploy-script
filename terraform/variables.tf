variable "TFC_AWS_ACCESS__KEY" {
  description = "AWS IAM access key"
  type        = string
}

variable "TFC_AWS_SECRET_ACCESS_KEY" {
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

variable "public_key" {
  description = "public key content"
  type        = string
}

variable "private_key" {
  description = "private key"
  type        = string
}

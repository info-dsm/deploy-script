resource "cloudflare_record" "record" {
  name    = "tfc-workflow"
  type    = "A"
  value   = aws_instance.infodsm-ec2.public_ip
  zone_id = var.cloudflare_zone_id
  proxied = true
}

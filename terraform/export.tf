resource "local_file" "ansible_inventory" {
  content = <<-DOC
    webserver:
      hosts:
        host1:
          ansible_host: ${aws_instance.infodsm-ec2.public_ip}
          ansible_private_key_file: ${var.private_key_path}
          ansible_user: ubuntu
    DOC

  filename = "../ansible/playbooks/inventory/inventory.yaml"
}

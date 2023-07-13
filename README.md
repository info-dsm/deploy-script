# deploy-script
 Simple IaC(Ansible && Terraform) Code that makes simple EC2 and it adds record forward to EC2 made before as proxied mode.
 

## Terraform
```
terraform $ terraform apply
```
![graph dot](https://github.com/info-dsm/deploy-script/assets/59428479/a0f11fba-dd5b-4176-a367-579909d1a598)

## Ansible
```
ansible/playbooks $ $ ansible-playbook -i inventory/ deploy.yaml
```
![automation](https://github.com/info-dsm/deploy-script/assets/59428479/a6f98bf6-b6f7-4f97-b000-303fe6224f6d)





# Cation
This terraform code for cloudflare generates record as proxied mode, so I recommend you to download and use your origin signed certificates(that only can be used between cloudflare point and origin).
If you downlaod your origin certificates, you can upload your key under ```ansible/playbooks/roles/nginx/files/```.

Have a nice deployment. :)


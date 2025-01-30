https://github.com/hashicorp/terraform-aws-vault/blob/master/modules/install-vault/install-vault

https://releases.hashicorp.com/vault/1.16.14+ent/vault_1.16.14+ent_linux_amd64.zip


add step to create service and step that gets as a var the hcl vault config file and you know

<!-- Install options  -->
bash install_vault.sh --version 1.16.14+ent 
bash install_vault.sh --download-url https://releases.hashicorp.com/vault/1.16.14+ent/vault_1.16.14+ent_linux_amd64.zip
bash install_vault.sh 


<!-- Run -->
sudo bash run_vault.sh --path-to-config ./vault_config.hcl 

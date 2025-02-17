# Vault Cluster on vm

Based on:
1. [install-vault](https://github.com/hashicorp/terraform-aws-vault/blob/master/modules/install-vault/README.md)
2. [run-vault](https://github.com/hashicorp/terraform-aws-vault/blob/master/modules/run-vault/README.md)

## Make sure before
1. Binary exists
2. if /usr/local/bin in PATH

## Install options 
bash install_vault.sh --version 1.16.14+ent 
bash install_vault.sh --download-url https://releases.hashicorp.com/vault/1.16.14+ent/vault_1.16.14+ent_linux_amd64.zip
bash install_vault.sh 

## Run
Create the files:
* vault_config.hcl
* vault.env
* tls_cert_file, tls_key_file and place in /opt/vault/tls and chown it for vault
* place your license in /opt/vault/config/license.hclic and **chown** it for vault

sudo bash run_vault.sh --path-to-config ./vault_config.hcl --path-to-env-file ./vault.env


# Hardining

For [Documantation](https://developer.hashicorp.com/vault/docs/concepts/production-hardening?productSlug=vault&tutorialSlug=operations&tutorialSlug=)

## Turn of swap?

To check if swap is on
```bash
cat /proc/swaps # check
vmstat # check
sudo swapon --show # check
```

To turn it off
```bash
sudo swapoff -a # do
# and delete all swap from: /etc/fstab
```

## Turn of histry - ? 
add to /etc/profile and /etc/bashrc:

```bash
unset HISTFILE
set +o history
export HISTSIZE=0
export HISTFILESIZE=0
```

then run 

```bash
source /etc/bashrc
source /etc/profile
```

## For auto rotate secret in azure click [here](https://learn.microsoft.com/en-us/azure/key-vault/secrets/tutorial-rotation-dual?tabs=azure-cli)


# Checks

setenforce 0

getenforce


getcap /usr/local/bin/vault

<!-- not used because selinux is disabled
sudo chcon -t bin_t /usr/local/bin/vault
sudo semanage fcontext -a -t bin_t /usr/local/bin/vault
sudo restorecon -v /usr/local/bin/vault -->



GET THEIR CONFIGRUTAION


To make this run on the vm itself with out use the env var:

sudo cp /Application/vault/tls/vault.ca /etc/pki/ca-trust/source/anchors/vault-ca.crt
sudo update-ca-trust
sudo trust list | grep vault-ca


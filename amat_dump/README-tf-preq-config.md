# Terraform setup

1. Create a terraform-policy (used admin policy)
vault policy write terraform-policyy /tmp/terraform-policy.hcl

2. Create approle 
```bash
vault auth enable approle

vault write auth/approle/role/terraform-role \
  token_policies="terraform-policy" \
  secret_id_ttl=0 \
  token_ttl=3600 \
  token_max_ttl=7200 \
  token_num_uses=0


vault read auth/approle/role/terraform-role/role-id
vault write -f auth/approle/role/terraform-role/secret-id
```

3. Config in tf

in the tf provider:

```java
provider "vault" {
  address = var.vault_addr
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}

variable "vault_role_id" {
  type      = string
  sensitive = true
}

variable "vault_secret_id" {
  type      = string
  sensitive = true
}
```



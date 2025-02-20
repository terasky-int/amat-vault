#######################################
# Vault Audit
#######################################

# For now wasn't used
# module "vault_audit" {
#   source = "./modules/vault_audit"

#   audit_devices = var.audit_devices
# }

#######################################
# Vault OIDC
#######################################
# Link for setup: https://support.hashicorp.com/hc/en-us/articles/18678253076627-How-to-configure-Ping-Identity-OIDC-authentication-with-Vault

module "vault_oidc" {
  source = "./modules/vault_oidc"

  vault_addr    = var.vault_addr
  discovery_url = var.oidc_discovery_url
  mount_path    = var.oidc_mount_path

  client_id       = var.oidc_client_id
  client_secret   = var.oidc_client_secret
  bound_audiences = var.oidc_bound_audiences
  roles           = var.oidc_roles

  depends_on = [ vault_policy.policy ]
}

#######################################
# Vault Policies
#######################################

resource "vault_policy" "policy" {
  for_each = fileset("policies", "*.hcl")  # Get all .hcl files in the "policies" directory

  name   = replace(each.value, ".hcl", "")
  policy = file("policies/${each.value}")
}
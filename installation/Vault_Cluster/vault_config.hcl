storage "raft" {
    node_id = "node-01"
    path    = "/opt/vault/data"
}

listener "tcp" {
  address         = "10.0.0.25:8200"
  #   cluster_address = "10.0.0.25:8201"
  tls_disable     = 1
#   tls_cert_file   = "$tls_cert_file"
#   tls_key_file    = "$tls_key_file"
}


seal "azurekeyvault" {
  client_id      = "YOUR-APP-ID"
  client_secret  = "YOUR-APP-PASSWORD"
  tenant_id      = "YOUR-AZURE-TENANT-ID"
  vault_name     = "Test-vault-XXXXXX"
  key_name       = "generated-key"
}

# HA settings
api_addr      = "http://10.0.0.25:8200"
cluster_addr  = "http://10.0.0.25:8201"
ui            = true
disable_mlock = true
license_path = "/opt/vault/config/license.hclic"

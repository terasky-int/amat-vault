api_addr      = "https://usauscosmpcn01.amat.com:8200"
cluster_addr  = "https://usauscosmpcn01.amat.com:8201"
license_path  = "/Application/vault/config/license.hclic"
disable_mlock = true
ui            = true
 
# enable_multiseal = true
 
storage "raft" {
  node_id = "vault-node-1"
  path    = "/Application/vault/data/"
}
 
listener "tcp" {
  tls_disable     = 0
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"

  tls_cert_file      = "/Application/vault/tls/vault.crt"
  tls_key_file       = "/Application/vault/tls/vault.key"
  tls_client_ca_file = "/Application/vault/tls/vault.ca"

  # Enable unauthenticated metrics access (necessary for Prometheus Operator)
  telemetry {
    unauthenticated_metrics_access = "true"
  }
}
 
log_level = "info"
log_format = "standard"
 
seal "azurekeyvault" {
  name     = "primary"
  priority = "1"
}
 
# seal "azurekeyvault" {
#   name     = "secondary"
#   priority = "2"
# }

telemetry {
  dogstatsd_addr = "localhost:8125"
  enable_hostname_label = true
  prometheus_retention_time = "0h"
}
storage "raft" {
  path    = "/opt/vault/data"
}

listener "tcp" {
  address         = "10.0.0.54:8200"
  cluster_address = "10.0.0.54:8201"
  tls_disable     = 1
#   tls_cert_file   = "$tls_cert_file"
#   tls_key_file    = "$tls_key_file"
  telemetry {
    unauthenticated_metrics_access = true
  }

}

seal "azurekeyvault" {}

telemetry {
  disable_hostname = true
  prometheus_retention_time = "24h"
}

# HA settings
api_addr      = "http://10.0.0.54:8200"
cluster_addr  = "http://10.0.0.54:8201"
license_path = "/opt/vault/config/license.hclic"
ui            = true
disable_mlock = true

ui = true
storage "file" {
    path    = "/vault"
}

backend "file" {
  path = "/vault/file"
}

listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "0.0.0.0:8201"
  tls_disable      = "true"
}
api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"
log_level = "Debug"
default_lease_ttl = "168h"
max_lease_ttl = "720h"

disable_mlock = true
terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "1.0.0" # Or the latest version available
    }
  }
}

provider "incus" {
  generate_client_certificates = true
  accept_remote_certificate    = true
  default_remote               = "kraken"

  remote {
    name    = "kraken"
    address = "https://192.168.100.2:8443"
  }
}

resource "incus_storage_pool" "local" {
  project = "default"
  name    = "local"
  driver  = "btrfs"
}

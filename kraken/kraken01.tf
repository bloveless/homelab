resource "incus_storage_volume" "caddy_config" {
  project = "default"
  name = "caddy-config"
  pool = incus_storage_pool.local.name
}

resource "incus_storage_volume" "caddy_data" {
  project = "default"
  name = "caddy-data"
  pool = incus_storage_pool.local.name
}

resource "incus_instance" "caddy" {
  project = "default"
  name = "caddy"
  image = "docker:bloveless/caddy:2.10.2-0.1.0"
  running = true
  target = "kraken01"

  config = {
    "boot.autostart" = true
    "boot.autorestart" = true
    "environment.CF_API_KEY" = var.cf_api_key
  }

  device {
    name = "caddy-config"
    type = "disk"
    properties = {
      path = "/etc/caddy"
      pool = incus_storage_volume.caddy_config.pool
      source = incus_storage_volume.caddy_config.name
    }
  }

  device {
    name = "caddy-data"
    type = "disk"
    properties = {
      path = "/data"
      pool = incus_storage_volume.caddy_data.pool
      source = incus_storage_volume.caddy_data.name
    }
  }

  wait_for {
    type = "ready"
  }
}

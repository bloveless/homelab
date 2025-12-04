resource "incus_instance" "tools" {
  project = "default"
  name    = "tools"
  image   = "images:fedora/43"
  target  = "kraken01"

  config = {
    "boot.autostart" = true
    "limits.cpu"     = 1
  }

  lifecycle {
    ignore_changes = [device]
  }
}

resource "incus_storage_volume" "caddy_config" {
  project = "default"
  name    = "caddy-config"
  pool    = incus_storage_pool.local.name
  target  = "kraken01"
}

resource "incus_storage_volume" "caddy_data" {
  project = "default"
  name    = "caddy-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken01"
}

resource "incus_instance" "caddy" {
  project = "default"
  name    = "caddy"
  image   = "docker:bloveless/caddy:2.10.2-0.1.0"
  running = true
  target  = "kraken01"

  config = {
    "boot.autostart"         = true
    "boot.autorestart"       = true
    "environment.CF_API_KEY" = var.cf_api_key
  }

  device {
    name = "caddy-config"
    type = "disk"
    properties = {
      path   = "/etc/caddy"
      pool   = incus_storage_volume.caddy_config.pool
      source = incus_storage_volume.caddy_config.name
    }
  }

  device {
    name = "caddy-data"
    type = "disk"
    properties = {
      path   = "/data"
      pool   = incus_storage_volume.caddy_data.pool
      source = incus_storage_volume.caddy_data.name
    }
  }
}

resource "incus_instance" "fritzandandre" {
  project = "default"
  name    = "fritzandandre"
  image   = "bloveless-ghcr:bloveless/fritzandandre.com:sha-933e05f"
  running = true
  target  = "kraken01"

  config = {
    "boot.autostart"                    = true
    "boot.autorestart"                  = true
    "environment.ADMIN_THEME"           = "pyrocms.theme.accelerant"
    "environment.APPLICATION_DOMAIN"    = "fritzandandre.com"
    "environment.APPLICATION_NAME"      = "Fritz And Andre"
    "environment.APPLICATION_REFERENCE" = "fna"
    "environment.APP_DEBUG"             = "false"
    "environment.APP_TIMEZONE"          = "America/Denver"
    "environment.APP_URL"               = "https://fritzandandre.com/"
    "environment.DB_HOST"               = "mariadb.lan.brennonloveless.com"
    "environment.DB_PORT"               = "3306"
    "environment.DB_DATABASE"           = "fritzandandre"
    "environment.DB_PREFIX"             = "fna_"
    "environment.DEFAULT_LOCALE"        = "en"
    "environment.INSTALLED"             = "true"
    "environment.STANDARD_THEME"        = "fritzandandre.theme.fna"
    "environment.SALESFORCE_WSDL"       = "wsdl/partner.wsdl"
    "environment.APP_KEY"               = var.fritzandandre_app_key
    "environment.DB_USERNAME"           = "fritzandandre"
    "environment.DB_PASSWORD"           = var.fritzandandre_db_password
  }

  device {
    name = "fritzandandre-data"
    type = "disk"
    properties = {
      path   = "/app/public/app"
      source = "/mnt/homelab/fritzandandre/fritzandandre.com/public"
    }
  }
}

resource "incus_storage_volume" "radarr_data" {
  project = "default"
  name    = "radarr-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken01"
}

resource "incus_instance" "radarr" {
  project = "default"
  name    = "radarr"
  image   = "docker:linuxserver/radarr:6.0.4"
  running = true
  target  = "kraken01"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
    "raw.idmap"        = "both 1000 1000"
    "environment.PUID" = "1000"
    "environment.PGID" = "1000"
  }

  device {
    name = "radarr-data"
    type = "disk"
    properties = {
      path   = "/config"
      pool   = incus_storage_volume.radarr_data.pool
      source = incus_storage_volume.radarr_data.name
    }
  }

  device {
    name = "radarr-media"
    type = "disk"
    properties = {
      source = "/mnt/media"
      path   = "/mnt/media"
    }
  }

  device {
    name = "radarr-backups"
    type = "disk"
    properties = {
      source = "/mnt/backups/radarr"
      path   = "/backups"
    }
  }
}

resource "incus_storage_volume" "seerr_data" {
  project = "default"
  name    = "seerr-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken01"
}

resource "incus_instance" "seerr" {
  project = "default"
  name    = "seerr"
  image   = "docker:seerr/seerr:develop"
  running = true
  target  = "kraken01"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
    "environment.TZ"   = "Ameria/Los_Angeles"
  }

  device {
    name = "seerr-data"
    type = "disk"
    properties = {
      path   = "/app/config"
      pool   = incus_storage_volume.seerr_data.pool
      source = incus_storage_volume.seerr_data.name
    }
  }
}

resource "incus_storage_volume" "profilarr_data" {
  project = "default"
  name    = "profilarr-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken01"
}

resource "incus_instance" "profilarr" {
  project = "default"
  name    = "profilarr"
  image   = "docker:santiagosayshey/profilarr:v1.1.3"
  running = true
  target  = "kraken01"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
    "environment.TZ"   = "America/Los_Angeles"
  }

  device {
    name = "profilarr-data"
    type = "disk"
    properties = {
      path   = "/config"
      pool   = incus_storage_volume.profilarr_data.pool
      source = incus_storage_volume.profilarr_data.name
    }
  }
}

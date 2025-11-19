resource "incus_storage_volume" "postgres_data" {
  project = "default"
  name    = "postgres-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken02"
}

resource "incus_instance" "postgres" {
  project = "default"
  name    = "postgres"
  image   = "docker:postgres:18"
  running = true
  target  = "kraken02"

  config = {
    "boot.autostart"                = true
    "boot.autorestart"              = true
    "environment.POSTGRES_PASSWORD" = var.postgres_password
  }

  device {
    name = "postgres-data"
    type = "disk"
    properties = {
      path   = "/var/lib/postgresql/18/docker"
      pool   = incus_storage_volume.postgres_data.pool
      source = incus_storage_volume.postgres_data.name
    }
  }
}

# Had trouble running tailscale in an oci container
resource "incus_instance" "tailscale" {
  project = "default"
  name    = "tailscale"
  image   = "images:fedora/43"
  running = true
  target  = "kraken02"

  config = {
    "boot.autostart" = true
  }
}

resource "incus_storage_volume" "fileflows_data" {
  project = "default"
  name    = "fileflows-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken02"
}

resource "incus_storage_volume" "fileflows_temp" {
  project = "default"
  name    = "fileflows-temp"
  pool    = incus_storage_pool.local.name
  target  = "kraken02"
}

resource "incus_storage_volume" "fileflows_common" {
  project = "default"
  name    = "fileflows-common"
  pool    = incus_storage_pool.local.name
  target  = "kraken02"
}

resource "incus_instance" "fileflows" {
  project = "default"
  name    = "fileflows"
  image   = "docker:revenz/fileflows:25.11"
  running = true
  target  = "kraken02"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
    # container must be run as root so it has access to the GPU but this mapping says that the root
    # user is mapped to 1000 outside of the container (really only on the /mnt/media mount) so this
    # should be secure enough
    "raw.idmap"                = "both 1000 0"
    "environment.PUID"         = "0"
    "environment.PGID"         = "0"
    "environment.TempPathHost" = "/temp"
    "environment.TZ"           = "America/Los_Angeles"
  }

  device {
    name = "fileflows-data"
    type = "disk"
    properties = {
      pool   = incus_storage_volume.fileflows_data.pool
      source = incus_storage_volume.fileflows_data.name
      path   = "/app/Data"
    }
  }

  device {
    name = "fileflows-temp"
    type = "disk"
    properties = {
      pool   = incus_storage_volume.fileflows_temp.pool
      source = incus_storage_volume.fileflows_temp.name
      path   = "/temp"
    }
  }

  device {
    name = "fileflows-common"
    type = "disk"
    properties = {
      pool   = incus_storage_volume.fileflows_common.pool
      source = incus_storage_volume.fileflows_common.name
      path   = "/app/common"
    }
  }

  device {
    name = "fileflows-media"
    type = "disk"
    properties = {
      source = "/mnt/media"
      path   = "/mnt/media"
    }
  }

  device {
    name = "qsv"
    type = "gpu"
    properties = {
      "gputype" = "physical"
      "pci"     = "0000:00:02.0"
    }
  }
}

resource "incus_storage_volume" "sonarr_data" {
  project = "default"
  name    = "sonarr-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken01"
}

resource "incus_instance" "sonarr" {
  project = "default"
  name    = "sonarr"
  image   = "docker:linuxserver/sonarr:4.0.16"
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
    name = "sonarr-data"
    type = "disk"
    properties = {
      path   = "/config"
      pool   = incus_storage_volume.sonarr_data.pool
      source = incus_storage_volume.sonarr_data.name
    }
  }

  device {
    name = "sonarr-media"
    type = "disk"
    properties = {
      source = "/mnt/media"
      path   = "/mnt/media"
    }
  }

  device {
    name = "sonarr-backups"
    type = "disk"
    properties = {
      source = "/mnt/backups/sonarr"
      path   = "/backups"
    }
  }
}

resource "incus_storage_volume" "cleanuparr_data" {
  project = "default"
  name    = "cleanuparr-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken02"
}

resource "incus_instance" "cleanuparr" {
  project = "default"
  name    = "cleanuparr"
  image   = "ghcr:cleanuparr/cleanuparr:2.4"
  running = true
  target  = "kraken02"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
    "environment.PUID" = "1000"
    "environment.PGID" = "1000"
  }

  device {
    name = "cleanuparr-data"
    type = "disk"
    properties = {
      path   = "/config"
      pool   = incus_storage_volume.cleanuparr_data.pool
      source = incus_storage_volume.cleanuparr_data.name
    }
  }
}

resource "incus_storage_volume" "prometheus_config" {
  project = "default"
  name    = "prometheus-config"
  pool    = incus_storage_pool.local.name
  target  = "kraken02"
}

resource "incus_storage_volume" "prometheus_data" {
  project = "default"
  name    = "prometheus-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken02"
}

resource "incus_instance" "prometheus" {
  project = "default"
  name    = "prometheus"
  image   = "docker:prom/prometheus:v3.7.3"
  running = true
  target  = "kraken02"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
  }

  device {
    name = "prometheus-config"
    type = "disk"
    properties = {
      path   = "/etc/prometheus"
      pool   = incus_storage_volume.prometheus_config.pool
      source = incus_storage_volume.prometheus_config.name
    }
  }

  device {
    name = "prometheus-data"
    type = "disk"
    properties = {
      path   = "/prometheus"
      pool   = incus_storage_volume.prometheus_data.pool
      source = incus_storage_volume.prometheus_data.name
    }
  }
}

resource "incus_storage_volume" "mariadb_data" {
  project = "default"
  name    = "mariadb-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken03"
}

resource "incus_instance" "mariadb" {
  project = "default"
  name    = "mariadb"
  image   = "docker:mariadb:12"
  running = true
  target  = "kraken03"

  config = {
    "boot.autostart"                    = true
    "boot.autorestart"                  = true
    "environment.MARIADB_ROOT_PASSWORD" = var.mariadb_root_password
  }

  device {
    name = "mariadb-data"
    type = "disk"
    properties = {
      path   = "/var/lib/mysql"
      pool   = incus_storage_volume.mariadb_data.pool
      source = incus_storage_volume.mariadb_data.name
    }
  }
}

resource "incus_instance" "brennonloveless" {
  project = "default"
  name    = "brennonloveless"
  image   = "docker:bloveless/brennonloveless-com:0.2.2"
  running = true
  target  = "kraken03"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
  }
}

resource "incus_storage_volume" "omada_data" {
  project = "default"
  name    = "omada-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken03"
}

resource "incus_storage_volume" "omada_logs" {
  project = "default"
  name    = "omada-logs"
  pool    = incus_storage_pool.local.name
  target  = "kraken03"
}

resource "incus_instance" "omada" {
  project = "default"
  name    = "omada"
  image   = "docker:mbentley/omada-controller:6.0-openj9"
  running = true
  target  = "kraken03"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
    "environment.TZ"   = "tls.America/Los_Angeles"
    # this strange format is required because of the * in the options which keeps getting escaped as \* unless it is double and single quoted
    "oci.entrypoint" = "'/entrypoint.sh java -server -Xms128m -Xmx1024m -XX:MaxHeapFreeRatio=60 -XX:MinHeapFreeRatio=30 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/tplink/EAPController/logs/java_heapdump.hprof -Djava.awt.headless=true --add-opens java.base/sun.security.x509=ALL-UNNAMED --add-opens java.base/sun.security.util=ALL-UNNAMED -cp /opt/tplink/EAPController/lib/*::/opt/tplink/EAPController/properties: com.tplink.smb.omada.starter.OmadaLinuxMain'"
  }

  device {
    name = "omada-data"
    type = "disk"
    properties = {
      path   = "/opt/tplink/EAPController/data"
      pool   = incus_storage_volume.omada_data.pool
      source = incus_storage_volume.omada_data.name
    }
  }

  device {
    name = "omada-logs"
    type = "disk"
    properties = {
      path   = "/opt/tplink/EAPController/logs"
      pool   = incus_storage_volume.omada_logs.pool
      source = incus_storage_volume.omada_logs.name
    }
  }
}

resource "incus_instance" "qbittorrent" {
  project = "default"
  name    = "qbittorrent"
  image   = "images:fedora/43"
  running = true
  target  = "kraken03"

  config = {
    "boot.autostart" = true
    "raw.idmap"      = "both 1000 1000"
  }

  device {
    name = "qbittorrent-media"
    type = "disk"
    properties = {
      source = "/mnt/media"
      path   = "/mnt/media"
    }
  }
}

resource "incus_storage_volume" "prowlarr_data" {
  project = "default"
  name    = "prowlarr-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken01"
}

resource "incus_instance" "prowlarr" {
  project = "default"
  name    = "prowlarr"
  image   = "docker:linuxserver/prowlarr:2.1.5"
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
    name = "prowlarr-data"
    type = "disk"
    properties = {
      path   = "/config"
      pool   = incus_storage_volume.prowlarr_data.pool
      source = incus_storage_volume.prowlarr_data.name
    }
  }

  device {
    name = "prowlarr-backups"
    type = "disk"
    properties = {
      source = "/mnt/backups/prowlarr"
      path   = "/backups"
    }
  }
}

resource "incus_storage_volume" "huntarr_data" {
  project = "default"
  name    = "huntarr-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken03"
}

resource "incus_instance" "huntarr" {
  project = "default"
  name    = "huntarr"
  image   = "docker:huntarr/huntarr:8.2.10"
  running = true
  target  = "kraken03"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
    "environment.TZ"   = "America/Los_Angeles"
    "raw.idmap"        = "both 1000 1000"
  }

  device {
    name = "huntarr-data"
    type = "disk"
    properties = {
      path   = "/config"
      pool   = incus_storage_volume.huntarr_data.pool
      source = incus_storage_volume.huntarr_data.name
    }
  }

  device {
    name = "huntarr-backups"
    type = "disk"
    properties = {
      source = "/mnt/backups/huntarr"
      path   = "/config/backups"
    }
  }
}

resource "incus_storage_volume" "grafana_data" {
  project = "default"
  name    = "grafana-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken03"
}

resource "incus_instance" "grafana" {
  project = "default"
  name    = "grafana"
  image   = "docker:grafana/grafana:12.2"
  running = true
  target  = "kraken03"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
  }

  device {
    name = "grafana-data"
    type = "disk"
    properties = {
      path   = "/var/lib/grafana"
      pool   = incus_storage_volume.grafana_data.pool
      source = incus_storage_volume.grafana_data.name
    }
  }
}

resource "incus_storage_volume" "jellyfin_data" {
  project = "default"
  name    = "jellyfin-data"
  pool    = incus_storage_pool.local.name
  target  = "kraken03"
}

resource "incus_storage_volume" "jellyfin_cache" {
  project = "default"
  name    = "jellyfin-cache"
  pool    = incus_storage_pool.local.name
  target  = "kraken03"
}

resource "incus_instance" "jellyfin" {
  project = "default"
  name    = "jellyfin"
  image   = "docker:jellyfin/jellyfin:10.11"
  running = true
  target  = "kraken03"

  config = {
    "boot.autostart"   = true
    "boot.autorestart" = true
    "oci.uid"          = "1000"
    "oci.gid"          = "1000"
    "raw.idmap"        = "both 1000 1000"
  }

  device {
    name = "jellyfin-data"
    type = "disk"
    properties = {
      pool   = incus_storage_volume.jellyfin_data.pool
      source = incus_storage_volume.jellyfin_data.name
      path   = "/config"
    }
  }

  device {
    name = "jellyfin-cache"
    type = "disk"
    properties = {
      pool   = incus_storage_volume.jellyfin_cache.pool
      source = incus_storage_volume.jellyfin_cache.name
      path   = "/cache"
    }
  }

  device {
    name = "jellyfin-media"
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
      "gid"     = "1000"
    }
  }
}

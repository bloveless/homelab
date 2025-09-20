job "media-server" {
  group "radarr" {
    network {
      mode = "bridge"
      port "http" {
        to = 7878
      }
    }

    volume "data" {
      type      = "host"
      source    = "radarr-data"
      read_only = false
    }

    service {
      name = "radarr"
      port = 7878 # cannot use port name here or connect won't work
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.radarr.rule=Host(`radarr.lan.brennonloveless.com`)",
        "traefik.http.routers.radarr.middlewares=crowdsec@file",
        "traefik.http.routers.radarr.middlewares=redirect-to-https@file",
      ]
      check {
        name = "healthz_probe"
        type = "http"
        port = "http"
        path = "/healthz"
        interval = "30s"
        timeout = "5s"
      }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "prowlarr"
              local_bind_port = 9696
            }
            upstreams {
              destination_name = "qbittorrent"
              local_bind_port = 8080
            }
            upstreams {
              destination_name = "sabnzbd"
              local_bind_port = 8081
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "linuxserver/radarr:5.23.3"
        ports = ["http"]

        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/radarr/backups"
          target = "/backups"
          readonly = false
        }

        mount {
          type = "bind"
          source = "/mnt/media"
          target = "/media"
          readonly = false
        }

        mount {
          type = "volume"
          source = "radarr-data"
          target = "/config"
          readonly = false
        }
      }

      env {
        TZ = "America/Los_Angeles"
        PGID = "1000"
        PUID = "1000"
      }

      resources {
        cpu    = 1000
        memory = 1024
      }
    }
  }

  group "sonarr" {
    network {
      mode = "bridge"
      port "http" {
        to = 8989
      }
    }

    volume "data" {
      type      = "host"
      source    = "sonarr-data"
      read_only = false
    }

    service {
      name = "sonarr"
      port = 8989 # cannot use port name here or connect won't work
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.sonarr.rule=Host(`sonarr.lan.brennonloveless.com`)",
        "traefik.http.routers.sonarr.middlewares=crowdsec@file",
        "traefik.http.routers.sonarr.middlewares=redirect-to-https@file",
      ]
      check {
        name = "healthz_probe"
        type = "http"
        port = "http"
        path = "/healthz"
        interval = "30s"
        timeout = "5s"
      }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "prowlarr"
              local_bind_port = 9696
            }
            upstreams {
              destination_name = "qbittorrent"
              local_bind_port = 8080
            }
            upstreams {
              destination_name = "sabnzbd"
              local_bind_port = 8081
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "linuxserver/sonarr:4.0.14"
        ports = ["http"]

        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/sonarr/backups"
          target = "/backups"
          readonly = false
        }

        mount {
          type = "bind"
          source = "/mnt/media"
          target = "/media"
          readonly = false
        }

        mount {
          type = "volume"
          source = "sonarr-data"
          target = "/config"
          readonly = false
        }
      }

      env {
        TZ = "America/Los_Angeles"
        PGID = "1000"
        PUID = "1000"
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }
  }

  group "prowlarr" {
    network {
      mode = "bridge"
      port "http" {
        to = 9696
      }
    }

    volume "data" {
      type      = "host"
      source    = "prowlarr-data"
      read_only = false
    }

    service {
      name = "prowlarr"
      port = 9696 # cannot use port name here or connect won't work
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.prowlarr.rule=Host(`prowlarr.lan.brennonloveless.com`)",
        "traefik.http.routers.prowlarr.middlewares=crowdsec@file",
        "traefik.http.routers.prowlarr.middlewares=redirect-to-https@file",
      ]
      check {
        name = "healthz_probe"
        type = "http"
        port = "http"
        path = "/healthz"
        interval = "30s"
        timeout = "5s"
      }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "radarr"
              local_bind_port = 7878
            }
            upstreams {
              destination_name = "sonarr"
              local_bind_port = 8989
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "linuxserver/prowlarr:1.35.1"
        ports = ["http"]

        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/prowlarr/backups"
          target = "/backups"
          readonly = false
        }

        mount {
          type = "volume"
          source = "prowlarr-data"
          target = "/config"
          readonly = false
        }
      }

      env {
        TZ = "America/Los_Angeles"
        PGID = "1000"
        PUID = "1000"
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }
  }

  group "qbittorrent" {
    network {
      mode = "bridge"
      port "http" {
        to = 8080
      }
    }

    service {
      name = "qbittorrent"
      port = 8080
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.lan.brennonloveless.com`)",
        "traefik.http.routers.qbittorrent.middlewares=crowdsec@file",
        "traefik.http.routers.qbittorrent.middlewares=redirect-to-https@file",
      ]
      # check {
      #   name = "home_probe"
      #   type = "http"
      #   port = "http"
      #   path = "/"
      #   interval = "30s"
      #   timeout = "5s"
      # }
      connect {
        sidecar_service {}
      }
    }

    task "wireguard" {
      driver = "docker"
      config {
        image = "lscr.io/linuxserver/wireguard:latest"
        cap_add = ["net_admin", "net_raw"]
        # Mount the config directory from the allocation into the container
        mount {
          type = "bind"
          source = "config/wg_confs"
          target = "/config/wg_confs"
        }
        sysctl = {
          "net.ipv4.conf.all.src_valid_mark" = "1"
        }
      }

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "america/los_angeles"
      }

      template {
        data = <<EOH
{{ with nomadVar "nomad/jobs/media-server/qbittorrent/wireguard" }}
[Interface]
PrivateKey = {{.private_key}}
Address = {{.address}}
DNS = {{.dns}}
# Allow local traffic
PostUp = DROUTE=$(ip route | grep default | awk '{print $3}'); ip route add 192.168.0.0/16 via $DROUTE;
PostUp = DROUTE=$(ip route | grep default | awk '{print $3}'); ip route add 172.16.0.0/16 via $DROUTE;
PreDown = DROUTE=$(ip route | grep default | awk '{print $3}'); ip route del 192.168.0.0/16 via $DROUTE;
PreDown = DROUTE=$(ip route | grep default | awk '{print $3}'); ip route del 172.16.0.0/16 via $DROUTE;

[Peer]
PublicKey = {{.public_key}}
AllowedIPs = 0.0.0.0/0
Endpoint = {{.endpoint}}
{{ end }}
EOH

        destination = "config/wg_confs/wg0.conf"
        perms = "0600"
      }

      resources {
        cpu = 100
        memory = 128
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "qbittorrentofficial/qbittorrent-nox:5.1.2-1"
        ports = ["http"]

        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/qbittorrent/data"
          target = "/config"
          readonly = false
        }

        mount {
          type = "bind"
          source = "/mnt/media"
          target = "/media"
          readonly = false
        }
      }

      env {
        TZ = "America/Los_Angeles"
        PGID = "1000"
        PUID = "1000"
        QBT_LEGAL_NOTICE = "confirm"
        WEBUI_PORT = "${NOMAD_PORT_http}"
        TORRENTING_PORT = 54058 # torrenting port open on ovpn
      }

      resources {
        cpu = 2000
        memory = 1024
      }
    }
  }

  group "sabnzbd" {
    network {
      mode = "bridge"
      port "http" {
        to = 8080
      }
    }

    service {
      name = "sabnzbd"
      port = 8080
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.sabnzbd.rule=Host(`sabnzbd.lan.brennonloveless.com`)",
        "traefik.http.routers.sabnzbd.middlewares=crowdsec@file",
        "traefik.http.routers.sabnzbd.middlewares=redirect-to-https@file",
      ]
      check {
        name = "home_probe"
        type = "http"
        port = "http"
        path = "/"
        interval = "30s"
        timeout = "5s"
      }
      connect {
        sidecar_service {}
      }
    }

    task "wireguard" {
      driver = "docker"
      config {
        image = "lscr.io/linuxserver/wireguard:latest"
        cap_add = ["net_admin", "net_raw"]
        # Mount the config directory from the allocation into the container
        mount {
          type = "bind"
          source = "config/wg_confs"
          target = "/config/wg_confs"
        }
        sysctl = {
          "net.ipv4.conf.all.src_valid_mark" = "1"
        }
      }

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "america/los_angeles"
      }

      template {
        data = <<EOH
{{ with nomadVar "nomad/jobs/media-server/sabnzbd/wireguard" }}
[Interface]
PrivateKey = {{.private_key}}
Address = {{.address}}
DNS = {{.dns}}
# Allow local traffic
PostUp = DROUTE=$(ip route | grep default | awk '{print $3}'); ip route add 192.168.0.0/16 via $DROUTE;
PostUp = DROUTE=$(ip route | grep default | awk '{print $3}'); ip route add 172.16.0.0/16 via $DROUTE;
PreDown = DROUTE=$(ip route | grep default | awk '{print $3}'); ip route del 192.168.0.0/16 via $DROUTE;
PreDown = DROUTE=$(ip route | grep default | awk '{print $3}'); ip route del 172.16.0.0/16 via $DROUTE;

[Peer]
PublicKey = {{.public_key}}
AllowedIPs = 0.0.0.0/0
Endpoint = {{.endpoint}}
{{ end }}
EOH

        destination = "config/wg_confs/wg0.conf"
        perms = "0600"
      }

      resources {
        cpu = 100
        memory = 128
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "linuxserver/sabnzbd:4.5.1"
        ports = ["http"]

        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/sabnzbd/data"
          target = "/config"
          readonly = false
        }

        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/sabnzbd/backups"
          target = "/backups"
          readonly = false
        }

        mount {
          type = "bind"
          source = "/mnt/media"
          target = "/media"
          readonly = false
        }
      }

      env {
        TZ = "America/Los_Angeles"
        PGID = "1000"
        PUID = "1000"
      }

      resources {
        cpu = 250
        memory = 256
      }
    }
  }

  # group "overseerr" {
  #   network {
  #     mode = "bridge"
  #     port "http" {
  #       to = 5055
  #     }
  #   }

  #   service {
  #     name = "overseerr"
  #     port = 5055 # cannot use port name here or connect won't work
  #     tags = [
  #       "traefik.enable=true",
  #       "traefik.consulcatalog.connect=true",
  #       "traefik.http.routers.overseerr.rule=Host(`overseerr.brennonloveless.com`)",
  #       "traefik.http.routers.overseerr.middlewares=crowdsec@file",
  #       "traefik.http.routers.overseerr.middlewares=redirect-to-https@file",
  #     ]
  #     connect {
  #       sidecar_service {
  #         proxy {
  #           upstreams {
  #             destination_name = "radarr"
  #             local_bind_port = 7878
  #           }
  #           upstreams {
  #             destination_name = "sonarr"
  #             local_bind_port = 8989
  #           }
  #         }
  #       }
  #     }
  #   }

  #   task "server" {
  #     driver = "docker"

  #     config {
  #       image = "linuxserver/overseerr:1.34.0"
  #       ports = ["http"]

  #       mount {
  #         type = "bind"
  #         source = "/mnt/homelab/media-server/overseerr/data"
  #         target = "/config"
  #         readonly = false
  #       }

  #       mount {
  #         type = "bind"
  #         source = "/mnt/media"
  #         target = "/media"
  #         readonly = false
  #       }
  #     }

  #     env {
  #       TZ = "America/Los_Angeles"
  #       PGID = "1000"
  #       PUID = "1000"
  #     }

  #     resources {
  #       cpu    = 250
  #       memory = 512
  #     }
  #   }
  # }

  group "jellyseerr" {
    network {
      mode = "bridge"
      port "http" {
        to = 5055
      }
    }

    service {
      name = "jellyseerr"
      port = 5055 # cannot use port name here or connect won't work
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.jellyseerr.rule=Host(`jellyseerr.brennonloveless.com`)",
        "traefik.http.routers.jellyseerr.middlewares=crowdsec@file",
        "traefik.http.routers.jellyseerr.middlewares=redirect-to-https@file",
      ]
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "radarr"
              local_bind_port = 7878
            }
            upstreams {
              destination_name = "sonarr"
              local_bind_port = 8989
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      user = "1000:1000"

      config {
        image = "fallenbagel/jellyseerr:2.5.2"
        ports = ["http"]

        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/jellyseerr/data"
          target = "/app/config"
          readonly = false
        }
      }

      env {
        TZ = "America/Los_Angeles"
        PGID = "1000"
        PUID = "1000"
      }

      resources {
        cpu    = 250
        memory = 512
      }
    }
  }

  group "huntarr" {
    network {
      mode = "bridge"
      port "http" {
        to = 9705
      }
    }


    volume "data" {
      type      = "host"
      source    = "huntarr-data"
      read_only = false
    }

    service {
      name = "huntarr"
      port = 9705
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.huntarr.rule=Host(`huntarr.lan.brennonloveless.com`)",
        "traefik.http.routers.huntarr.middlewares=crowdsec@file",
        "traefik.http.routers.huntarr.middlewares=redirect-to-https@file",
      ]
      # check {
      #   name = "health_probe"
      #   type = "http"
      #   port = "http"
      #   path = "/api/health"
      #   interval = "30s"
      #   timeout = "5s"
      # }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "radarr"
              local_bind_port = 7878
            }
            upstreams {
              destination_name = "sonarr"
              local_bind_port = 8989
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "huntarr/huntarr:8.1.11"
        ports = ["http"]

        mount {
          type = "volume"
          source = "huntarr-data"
          target = "/config"
          readonly = false
        }
      }

      env {
        TZ = "America/Los_Angeles"
      }

      resources {
        cpu = 250
        memory = 256
      }
    }
  }

  group "cleanuparr" {
    network {
      mode = "bridge"
      port "http" {
        to = 11011
      }
    }

    service {
      name = "cleanuparr"
      port = 11011
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.cleanuparr.rule=Host(`cleanuparr.lan.brennonloveless.com`)",
        "traefik.http.routers.cleanuparr.middlewares=crowdsec@file",
        "traefik.http.routers.cleanuparr.middlewares=redirect-to-https@file",
      ]
      check {
        name = "health_probe"
        type = "http"
        port = "http"
        path = "/"
        interval = "30s"
        timeout = "5s"
      }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "radarr"
              local_bind_port = 7878
            }
            upstreams {
              destination_name = "sonarr"
              local_bind_port = 8989
            }
            upstreams {
              destination_name = "qbittorrent"
              local_bind_port = 8080
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "ghcr.io/cleanuparr/cleanuparr:2.0.14"
        ports = ["http"]

        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/cleanuparr/data"
          target = "/config"
          readonly = false
        }
      }

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "America/Los_Angeles"
      }

      resources {
        cpu = 250
        memory = 512
      }
    }
  }

  group "profilarr" {
    network {
      mode = "bridge"
      port "http" {
        to = 6868
      }
    }

    service {
      name = "profilarr"
      port = 6868
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.cleanuparr.rule=Host(`profilarr.lan.brennonloveless.com`)",
        "traefik.http.routers.cleanuparr.middlewares=crowdsec@file",
        "traefik.http.routers.cleanuparr.middlewares=redirect-to-https@file",
      ]
      check {
        name = "health_probe"
        type = "http"
        port = "http"
        path = "/"
        interval = "30s"
        timeout = "5s"
      }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "radarr"
              local_bind_port = 7878
            }
            upstreams {
              destination_name = "sonarr"
              local_bind_port = 8989
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "santiagosayshey/profilarr:v1.1.3"
        mount {
          type = "bind"
          source = "/mnt/homelab/media-server/profilarr/data"
          target = "/config"
          readonly = false
        }
      }

      env {
        TZ = "America/Los_Angeles"
        PGID = "1000"
        PUID = "1000"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}

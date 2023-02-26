job "mediaserver" {
  datacenters = ["homelab01"]
  type = "service"

  # wireguard
  # netshoot
  # nzbget
  # qbittorrent
  # radarr
  # sonarr
  # overseerr
  # prowlarr
  # flaresolverr

  group "webserver" {
    count = 1
    network {
      port "http" {
        to = 80
      }
    }

    restart {
      attempts = 10
      interval = "10m"
      delay    = "30s"
      mode     = "delay"
    }

    task "hugo" {
      driver = "docker"
      config {
        image = "bloveless/brennonloveless-com:0.2.2"
        ports = ["http"]
      }

      service {
        name = "brennonloveless-com-webserver"
        tags = [
              "urlprefix-brennonloveless.com/",
              "urlprefix-brennonloveless.lan.brennonloveless.com/"
            ]
        port = "http"
        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

job "publicip" {
  datacenters = ["homelab01"]
  type = "service"

  group "publicip-wireguard" {
    count = 1

    network {
      port "http" {
        to = 8090
      }
    }

    restart {
      attempts = 10
      interval = "10m"
      delay    = "30s"
      mode     = "delay"
    }

    task "wireguard-server" {
      driver = "docker"

      config {
        image = "docker.io/linuxserver/wireguard:1.0.20210914"
        privileged = "true"
        cap_add = ["NET_ADMIN"]
        sysctl = {
          "net.ipv4.conf.all.src_valid_mark" = "1",
          "net.ipv6.conf.all.disable_ipv6" = "0"
        }
        # Because the network stack is shared to dependent containers the ports actually need to be opened on the wreguard container
        ports = ["http"]
        volumes = [
          "/mnt/storage-nfs/media-server/wireguard/config/wg0.conf:/config/wg0.conf"
        ]
      }

      service {
        name = "publicip-webserver"
        tags = [ "urlprefix-publicip.lan.brennonloveless.com/" ]
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

    task "publicip-server" {
      driver = "docker"

      config {
        image = "bloveless/publicip:0.1.3"
        network_mode = "container:wireguard-server-${NOMAD_ALLOC_ID}"
      }
    }
  }
}

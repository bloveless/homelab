job "fabio" {
  datacenters = ["homelab01"]
  type = "system"

  group "fabio" {
    network {
      port "lb" {
        static = 9999
      }
      port "ui" {
        static = 9998
      }
    }

    restart {
      attempts = 10
      interval = "10m"
      delay    = "30s"
      mode     = "delay"
    }

    task "fabio" {
      driver = "docker"
      user = "nobody:nobody"

      config {
        image = "fabiolb/fabio"
        network_mode = "host"
        ports = ["lb","ui"]
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}

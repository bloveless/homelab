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
    task "fabio" {
      driver = "docker"

      template {
        data = <<EOH
CONSUL_TOKEN="{{with secret "nomad/jobs/fabio/CONSUL_TOKEN"}}{{.Data.value}}{{end}}"
EOH

        destination = "secrets/file.env"
        env         = true
      }

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

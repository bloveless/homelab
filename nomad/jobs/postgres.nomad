job "postgres" {
  datacenters = [ "homelab01" ]
  type = "service"

  group "postgres" {
    count = 1

    network {
      port "postgres" {
        static = 5432
      }
    }

    volume "postgres-data" {
      type = "host"
      read_only = false
      source = "postgres-data"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:15.2-bullseye"
        ports = [ "postgres" ]
      }
      
      template {
        data = <<EOH
POSTGRES_PASSWORD = "{{ with nomadVar "nomad/jobs/postgres" }}{{ .POSTGRES_PASSWORD }}{{ end }}"
EOH
        destination = "local/env"
        env = true
      }
      
      volume_mount {
        volume = "postgres-data"
        destination = "/var/lib/postgresql/data"
        read_only = false
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name = "postgres"
        port = "postgres"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

job "nginx-webserver" {
  datacenters = ["homelab01"]
  type = "service"

  group "webserver" {
    count = 1
    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "nginx-webserver"
      tags = ["urlprefix-/foo"]
      port = "http"
      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "nginx" {
      driver = "docker"
      config {
        image = "nginx:latest"
        ports = ["http"]
      }
    }
  }
}

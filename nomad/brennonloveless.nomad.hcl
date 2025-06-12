job "brennonloveless" {

  group "server" {
    network {
      port "http" {
        to = 80
      }
    }

    task "server" {
      driver = "docker"

      service {
        name = "brennonloveless"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.brennonloveless.rule=Host(`brennonloveless.com`) || Host(`www.brennonloveless.com`)",
          "traefik.http.routers.brennonloveless.middlewares=crowdsec@file,redirect-to-https@file,redirect-to-non-www@file",
        ]
        check {
          name = "home_probe"
          type = "http"
          port = "http"
          path = "/"
          interval = "30s"
          timeout = "5s"
        }
        check {
          name = "about_probe"
          type = "http"
          port = "http"
          path = "/about/"
          interval = "30s"
          timeout = "5s"
        }
      }

      config {
        image = "bloveless/brennonloveless-com:0.2.2"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}

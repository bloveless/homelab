job "whoami" {

  group "server" {
    network {
      port "http" {
        to = 80
      }
    }

    task "server" {
      driver = "docker"

      service {
        name = "whoami"
	port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.whoami.rule=Host(`whoami.lan.brennonloveless.com`)",
          "traefik.http.routers.whoami.tls.certResolver=",
        ]
      }

      config {
        image          = "traefik/whoami"
        ports          = ["http"]
        auth_soft_fail = true
      }

      identity {
        env  = true
        file = true
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }
  }
}

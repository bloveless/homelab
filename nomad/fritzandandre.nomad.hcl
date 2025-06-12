job "fritzandandre" {

  group "server" {
    network {
      port "http" {
        to = 8080
      }
    }

    task "prep-disk" {
      driver = "docker"
      config {
        image        = "ghcr.io/bloveless/fritzandandre.com:sha-09ce56e"
        command      = "sh"
        args         = ["-c", "chown -R unit:unit /fritzandandre-data/"]
        mount {
          type   = "bind"
          source = "/mnt/homelab/fritzandandre/fritzandandre.com/public"
          target = "/fritzandandre-data/"
          readonly = false
        }
      }
      resources {
        cpu    = 200
        memory = 128
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }

    task "server" {
      driver = "docker"

      service {
        name = "fritzandandre"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.fritzandandre.rule=Host(`fritzandandre.com`) || Host(`www.fritzandandre.com`)",
          "traefik.http.routers.fritzandandre.middlewares=crowdsec@file,redirect-to-https@file,redirect-to-non-www@file",
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
          name = "services_probe"
          type = "http"
          port = "http"
          path = "/services/"
          interval = "30s"
          timeout = "5s"
        }
      }

      config {
        image = "ghcr.io/bloveless/fritzandandre.com:sha-09ce56e"
        ports = ["http"]

        mount {
          type   = "bind"
          source = "/mnt/homelab/fritzandandre/fritzandandre.com/public"
          target = "/app/public/app"
          readonly = false
        }

        mount {
          type   = "bind"
          source = "local/env"
          target = "/app/.env"
        }
      }

      template {
        data = <<EOH
{{ with nomadVar "nomad/jobs/fritzandandre" }}
ADMIN_THEME = "pyrocms.theme.accelerant"
APPLICATION_DOMAIN = "fritzandandre.com"
APPLICATION_NAME = "Fritz And Andre"
APPLICATION_REFERENCE = "fna"
APP_DEBUG = "false"
APP_TIMEZONE = "America/Denver"
APP_URL = "https://fritzandandre.com/"
DB_HOST = "192.168.100.5"
DB_DATABASE = "fritzandandre"
DB_PREFIX = "fna_"
DEFAULT_LOCALE = "en"
INSTALLED = "true"
STANDARD_THEME = "fritzandandre.theme.fna"
SALESFORCE_WSDL = "wsdl/partner.wsdl"
APP_KEY = "{{.app_key}}"
DB_PASSWORD = "{{.db_password}}"
DB_USERNAME = "{{.db_username}}"
{{ end }}
EOH
        destination = "local/env"
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }
  }
}

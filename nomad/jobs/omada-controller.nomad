job "omada" {
  datacenters = [ "homelab01" ]
  type = "service"

  group "controller" {
    count = 1

    network {
      port "manage-http" {
        static = 8088
      }
      port "manage-https" {
        static = 8043
      }
      /* port "portal-http" { */
      /*   static = 8088 */
      /* } */
      port "portal-https" {
        static = 8843
      }
      port "adopt-v1" {
        static = 29812
      }
      port "app-discovery" {
        static = 27001
      }
      port "discovery" {
        static = 29810
      }
      port "manager-v1" {
        static = 29811
      }
      port "manager-v2" {
        static = 29814
      }
      port "upgrade-v1" {
        static = 29813
      }
    }

    volume "omada-controller-data" {
      type = "host"
      read_only = false
      source = "omada-controller-data"
    }
    
    volume "omada-controller-logs" {
      type = "host"
      read_only = false
      source = "omada-controller-logs"
    }

    restart {
      attempts = 10
      interval = "10m"
      delay    = "30s"
      mode     = "delay"
    }

    task "controller" {
      driver = "docker"

      config {
        image = "mbentley/omada-controller:5.8-chromium"
        ports = [ "manage-http", "manage-https", "portal-https", "adopt-v1", "app-discovery", "discovery", "manager-v1", "manager-v2", "upgrade-v1" ]
      }

      env {
        MANAGE_HTTP_PORT = "8088"
        MANAGE_HTTPS_PORT = "8043"
        PORTAL_HTTP_PORT = "8088"
        PORTAL_HTTPS_PORT = "8843"
        PORT_ADOPT_V1 = "29812"
        PORT_APP_DISCOVERY = "27001"
        PORT_DISCOVERY = "29810"
        PORT_MANAGER_V1 = "29811"
        PORT_MANAGER_V2 = "29814"
        PORT_UPGRADE_V1 = "29813"
        PUID = "1024"
        PGID = "100"
        SHOW_SERVER_LOGS = "true"
        SHOW_MONGODB_LOGS = "false"
        SSL_CERT_NAME = "tls.crt"
        SSL_KEY_NAME = "tls.key"
        TZ = "America/Los_Angeles"
      }
      
      volume_mount {
        volume = "omada-controller-data"
        destination = "/opt/tplink/EAPController/data"
        read_only = false
      }

      volume_mount {
        volume = "omada-controller-logs"
        destination = "/opt/tplink/EAPController/logs"
        read_only = false
      }

      resources {
        cpu    = 512
        memory = 1024
      }

      service {
        port = "manage-https"
        tags = [ "urlprefix-omada.lan.brennonloveless.com:8043/ proto=https tlsskipverify=true" ]

        check {
          type = "http"
          protocol = "https"
          tls_skip_verify = true
          path = "/"
          interval = "10s"
          timeout = "2m"
        }
      }
    }
  }
}

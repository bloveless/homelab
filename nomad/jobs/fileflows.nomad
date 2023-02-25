job "fileflows" {
  datacenters = [ "homelab01" ]
  type = "service"

  group "fileflows-server" {
    count = 1

    network {
      port "http" {
        to = 5000
      }
    }

    volume "fileflows-server-data" {
      type = "host"
      read_only = false
      source = "fileflows-server-data"
    }

    volume "fileflows-server-logs" {
      type = "host"
      read_only = false
      source = "fileflows-server-logs"
    }

    volume "fileflows-server-temp" {
      type = "host"
      read_only = false
      source = "fileflows-server-temp"
    }

    volume "media" {
      type = "host"
      read_only = false
      source = "media"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "fileflows-server" {
      driver = "docker"

      config {
        image = "revenz/fileflows:1.0.9"
        ports = [ "http" ]
        hostname = "fileflows-server"
        devices = [{
          host_path = "/dev/dri"
          container_path = "/dev/dri"
          cgroup_permissions = "rwm"
        }]
      }

      env {
        TZ = "America/Los_Angeles"
      }
      
      volume_mount {
        volume = "fileflows-server-data"
        destination = "/app/Data"
        read_only = false
      }

      volume_mount {
        volume = "fileflows-server-logs"
        destination = "/app/Logs"
        read_only = false
      }

      volume_mount {
        volume = "fileflows-server-temp"
        destination = "/app/Temp"
        read_only = false
      }

      volume_mount {
        volume = "media"
        destination = "/mnt/media"
        read_only = false
      }

      resources {
        cpu    = 4096
        memory = 4096
      }

      service {
        name = "fileflows-server"
        tags = [
          "urlprefix-fileflows.lan.brennonloveless.com/"
        ]
        port = "http"

        check {
          type = "http"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }

  group "fileflows-node" {
    count = 1

    network {
      port "fileflows" {
        to = 5000
      }
    }

    volume "fileflows-node-data" {
      type = "host"
      read_only = false
      source = "fileflows-node-data"
    }

    volume "fileflows-node-logs" {
      type = "host"
      read_only = false
      source = "fileflows-node-logs"
    }

    volume "fileflows-node-temp" {
      type = "host"
      read_only = false
      source = "fileflows-node-temp"
    }

    volume "media" {
      type = "host"
      read_only = false
      source = "media"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "fileflows-node" {
      driver = "docker"

      config {
        image = "revenz/fileflows:1.0.9"
        hostname = "fileflows-node"
        ports = [ "fileflows" ]
        devices = [{
          host_path = "/dev/dri"
          container_path = "/dev/dri"
          cgroup_permissions = "rwm"
        }]
      }
      
      env {
        FFNODE = "1"
        ServerUrl = "https://fileflows.lan.brennonloveless.com"
        TZ = "America/Los_Angeles"
      }
       
      volume_mount {
        volume = "fileflows-node-data"
        destination = "/app/Data"
        read_only = false
      }

      volume_mount {
        volume = "fileflows-node-logs"
        destination = "/app/Logs"
        read_only = false
      }

      volume_mount {
        volume = "fileflows-node-temp"
        destination = "/app/Temp"
        read_only = false
      }

      volume_mount {
        volume = "media"
        destination = "/mnt/media"
        read_only = false
      }

      resources {
        cpu    = 4096
        memory = 4096
      }
    }
  }
}

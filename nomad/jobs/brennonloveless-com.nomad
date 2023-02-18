job "brennonloveless-com" {
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
      name = "brennonloveless-com-webserver"
      tags = [
	    "urlprefix-brennonloveless.com/",
	    "urlprefix-brennonloveless.lan.brennonloveless.com/"
	  ]
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

    task "hugo" {
      driver = "docker"
      config {
        image = "bloveless/brennonloveless-com:0.2.2"
        ports = ["http"]
      }
    }
  }
}

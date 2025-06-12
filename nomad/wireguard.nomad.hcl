job "wireguard" {
  group "wireguard" {
    network {
      mode = "bridge"
    }

    task "wireguard" {
      driver = "docker"
      config {
        image = "lscr.io/linuxserver/wireguard:latest"
        cap_add = ["net_admin", "net_raw"]
        # Mount the config directory from the allocation into the container
        mount {
          type = "bind"
          source = "config/wg_confs"
          target = "/config/wg_confs"
        }
        sysctl = {
          "net.ipv4.conf.all.src_valid_mark" = "1"
        }
      }

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "america/los_angeles"
      }

      template {
        data = <<EOH
{{ with nomadVar "nomad/jobs/wireguard" }}
[Interface]
PrivateKey = {{.private_key}}
Address = {{.address}}
DNS = {{.dns}}
PostUp = DROUTE=$(ip route | grep default | awk '{print $3}'); HOMENET=192.168.0.0/16; ip route add $HOMENET via $DROUTE; iptables -I OUTPUT -d $HOMENET -j ACCEPT; iptables -A OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT;
PreDown = DROUTE=$(ip route | grep default | awk '{print $3}'); HOMENET=192.168.0.0/16; ip route del $HOMENET via $DROUTE; iptables -D OUTPUT -d $HOMENET -j ACCEPT; iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT;

[Peer]
PublicKey = {{.public_key}}
AllowedIPs = 0.0.0.0/0
Endpoint = {{.endpoint}}
{{ end }}
EOH 

        destination = "config/wg_confs/wg0.conf"
        perms = "0600"
      }
    }

    task "application" {
      driver = "docker"

      config {
        image = "alpine"
        command = "/bin/ash"

        extra_hosts = [
          "whoami.lan.brennonloveless.com:192.168.100.5",
        ]

        args = [
          "-c",
          "/bin/sleep infinity",
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}

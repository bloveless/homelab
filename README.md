# Homelab

Credentials are stored in 1Password

## Notes for CoreOS setup

These steps should be written into the ignition file in coreos/coreos.bu and converted into an ignition file so it can be recreated later

- created /etc/systemd/system/haproxy.service
- created /etc/systemd/system/cloudflared.service
- created /etc/containers/networks/podman.json
    - via https://github.com/containers/podman/blob/main/docs/tutorials/basic_networking.md
    - podman network inspect podman | jq .[] > /etc/containers/networks/podman.json
    - then enabled dns inside of podman.json
- TODO: add tailscale container


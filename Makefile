tools:
	TAILSCALE_KEY=op://Homelab/ToolsServer/TAILSCALE_KEY CLOUDFLARED_REFRESH_KEY=op://Homelab/ToolsServer/CLOUDFLARED_REFRESH_KEY op run -- ansible-playbook -i ansible/inventory.ini -K ansible/tools.yaml

deps:
	ansible-galaxy role install artis3n.tailscale


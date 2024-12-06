.PHONY: tools deps helm

tools:
	ANSIBLE_FORCE_COLOR=True \
	TAILSCALE_KEY=op://Homelab/ToolsServer/TAILSCALE_KEY \
		CLOUDFLARED_REFRESH_KEY=op://Homelab/ToolsServer/CLOUDFLARED_REFRESH_KEY \
		MARIADB_ROOT_PASSWORD=op://Homelab/ToolsServer/MARIADB_ROOT_PASSWORD \
		op run -- ansible-playbook -i ansible/inventory.ini ansible/tools.yaml

deps:
	ansible-galaxy role install artis3n.tailscale

helm:
	helmfile -f ./helm/helmfile.yaml apply

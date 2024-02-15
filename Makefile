.PHONY: tools deps helm

tools:
	TAILSCALE_KEY=op://Homelab/ToolsServer/TAILSCALE_KEY \
		CLOUDFLARED_REFRESH_KEY=op://Homelab/ToolsServer/CLOUDFLARED_REFRESH_KEY \
		op run -- ansible-playbook -i ansible/inventory.ini -K ansible/tools.yaml

deps:
	ansible-galaxy role install artis3n.tailscale

helm:
	GRAFANA_CLOUD_USERNAME="op://Homelab/GrafanaCloud/GRAFANA_CLOUD_USERNAME" \
		GRAFANA_CLOUD_PASSWORD="op://Homelab/GrafanaCloud/GRAFANA_CLOUD_PASSWORD" \
		GRAFANA_CLOUD_HOST="op://Homelab/GrafanaCloud/GRAFANA_CLOUD_HOST" \
		op run -- helmfile -f ./helm/helmfile.yaml apply

default: plan

.PHONY: init
init:
	tofu -chdir=kraken init

.PHONY: plan
plan:
	op run --env-file="./Makefile.env" -- sh -c 'tofu -chdir=kraken plan -var "cf_api_key=$$CF_API_KEY"'

.PHONY: apply
apply:
	op run --env-file="./Makefile.env" -- sh -c 'tofu -chdir=kraken apply -var "cf_api_key=$$CF_API_KEY"'

.PHONY: deps
deps:
	ansible-galaxy role install artis3n.tailscale

.PHONY: helm
helm:
	helmfile -f ./helm/helmfile.yaml apply

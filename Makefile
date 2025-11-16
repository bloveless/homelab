default: plan

.PHONY: init
init:
	tofu -chdir=kraken init

.PHONY: plan
plan:
	op run --env-file="./Makefile.env" -- sh -c 'tofu -chdir=kraken plan'

.PHONY: apply
apply:
	op run --env-file="./Makefile.env" -- sh -c 'tofu -chdir=kraken apply'

.PHONY: deps
deps:
	ansible-galaxy role install artis3n.tailscale

.PHONY: helm
helm:
	helmfile -f ./helm/helmfile.yaml apply

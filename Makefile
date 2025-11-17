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

.PHONY: kraken
kraken:
	ansible-playbook -i ./ansible/inventory.ini ./ansible/kraken.yaml

.PHONY: helm
helm:
	helmfile -f ./helm/helmfile.yaml apply

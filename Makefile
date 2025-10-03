.PHONY: tools deps helm

kraken:
	ansible-playbook -i ansible/inventory.ini ansible/kraken01.yaml ansible/kraken02.yaml ansible/kraken03.yaml

kraken01:
	ansible-playbook -i ansible/inventory.ini ansible/kraken01.yaml

kraken02:
	ansible-playbook -i ansible/inventory.ini ansible/kraken02.yaml

kraken03:
	ansible-playbook -i ansible/inventory.ini ansible/kraken03.yaml

deps:
	ansible-galaxy role install artis3n.tailscale

helm:
	helmfile -f ./helm/helmfile.yaml apply

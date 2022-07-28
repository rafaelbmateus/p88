include lib/makefile/help.mk

project = p88
version ?= latest
img = $(project):$(version)
vol = $(shell pwd):/$(project)
tags ?= all

pub_key ?= $(HOME)/.ssh/id_rsa.pub
pvt_key ?= $(HOME)/.ssh/id_rsa

terraform_vars = \
	-var "do_token=$(do_token)" \
	-var "pub_key=$(pub_key)" \
	-var "pvt_key=$(pvt_key)" \
	-var "ssh_fingerprint=$(do_fingerprint)"
	-target=module.$(module)

.PHONY: build
build: ##@docker Build and run docker image
	docker build . -t $(img)

.PHONY: bash
bash: ##@docker Get a tty bash inside docker container
	docker run -it \
		-v $(vol) \
		--rm $(img)

.PHONY: terraform-init
terraform-init: ##@terraform Init terraform of the app
	docker run \
		-w /$(project)/apps/$(app)/$(env)/terraform/ \
		-v $(vol) \
		--rm $(img) \
		terraform init

.PHONY: terraform-plan
terraform-plan: terraform-init ##@terraform Plan the infrastructure of the app
	docker run \
		-w /$(project)/apps/$(app)/$(env)/terraform/ \
		-v $(vol) \
		--rm $(img) \
		terraform plan -out=terraform.tfplan $(terraform_vars)

.PHONY: terraform-apply
terraform-apply: terraform-plan ##@terraform Create and apply the infrastructure of the app
	docker run -it \
		-w /$(project)/apps/$(app)/$(env)/terraform/ \
		-v $(vol) \
		--rm $(img) \
		terraform apply -parallelism=10 $(terraform_vars)

.PHONY: terraform-destroy
terraform-destroy: terraform-plan ##@terraform Destroy the infrastructure of the app
	docker run -it \
		-w /$(project)/apps/$(app)/$(env)/terraform/ \
		-v $(vol) \
		--rm $(img) \
		terraform destroy $(terraform_vars)

.PHONY: ansible
ansible: ##@ansible Apply ansible playbook to one app
	docker run -it \
		-w /$(project)/apps/$(app)/$(env)/ansible/ \
		-v $(vol) \
		-v $(pvt_key):/root/.ssh/id_rsa \
		-v $(pub_key):/root/.ssh/id_rsa.pub \
		--rm $(img) \
		ansible-playbook -i ./config.yml \
		--private-key /root/.ssh/id_rsa \
		./playbook.yml -t $(tags)

.PHONY: clean
clean: ##@docker Remove image
	docker rmi $(img)

project = p88
version ?= latest
img = $(project):$(version)
vol = $(shell pwd):/$(project)
username = devops
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
		-v $(pvt_key):/$(username)/.ssh/id_rsa \
		-v $(pub_key):/$(username)/.ssh/id_rsa.pub \
		--rm $(img) \
		ansible-playbook -i ./config.yml \
		--private-key /$(username)/.ssh/id_rsa \
		./playbook.yml -t $(tags)

.PHONY: clean
clean: ##@docker Remove image
	docker rmi $(img)

# make help
.DEFAULT_GOAL := help
GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

HELP_FUN = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
	print "usage: make [target]\n\n"; \
	for (sort keys %help) { \
	print "${WHITE}$$_:${RESET}\n"; \
	for (@{$$help{$$_}}) { \
	$$sep = " " x (32 - length $$_->[0]); \
	print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
	}; \
	print "\n"; }

.PHONY: help
help: ##@other Show this help.
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

.PHONY: azure aws gcp uninstall install get-cli setup-cli get-master-ip get-master-elb_ip plan-dcos launch-dcos detroy-dcos kubectl-config kubectl-tunnel plan deploy

RM := rm -f
SSH_USER := core
MASTER_IP_FILE := .master_ip
MASTER_LB_IP_FILE := .master_lb_ip
TERRAFORM_INSTALLER_URL := github.com/dcos/terraform-dcos
DCOS_CLI_VERSION := 0.5.7
KUBERNETES_VERSION := v1.9.0

get-cli:
	$(eval export DCOS_CLI_VERSION)
	$(eval export KUBERNETES_VERSION)
	scripts/get_cli

azure: clean
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.azure desired_cluster_profile; \
	cp ../resources/options.json.azure options.json; \
	terraform init -from-module $(TERRAFORM_INSTALLER_URL)/azure

aws: clean
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.aws desired_cluster_profile; \
	cp ../resources/options.json.aws options.json; \
	terraform init -from-module $(TERRAFORM_INSTALLER_URL)/aws

gcp: clean
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.gcp desired_cluster_profile; \
	cp ../resources/options.json.gcp options.json; \
	terraform init -from-module $(TERRAFORM_INSTALLER_URL)/gcp

install:
	dcos package install --yes beta-kubernetes --options=./.deploy/options.json

uninstall:
	dcos package uninstall --yes beta-kubernetes

setup-cli:
	$(call get_master_lb_ip)
	dcos cluster setup https://$(MASTER_LB_IP)

get-master-ip:
	$(call get_master_ip)
	@echo $(MASTER_IP)

define get_master_ip
$(shell test -f $(MASTER_IP_FILE) || \
	terraform output -state=.deploy/terraform.tfstate "Mesos Master Public IP" | head -1 > $(MASTER_IP_FILE))
$(eval MASTER_IP := $(shell cat $(MASTER_IP_FILE)))
endef

get-master-lb-ip:
	$(call get_master_lb_ip)
	@echo $(MASTER_LB_IP)

define get_master_lb_ip
$(shell test -f $(MASTER_LB_IP_FILE) || \
	terraform output -state=.deploy/terraform.tfstate "Master ELB Address" > $(MASTER_LB_IP_FILE))
$(eval MASTER_LB_IP := $(shell cat $(MASTER_LB_IP_FILE)))
endef

plan-dcos:
	cd .deploy; \
	terraform plan -var-file desired_cluster_profile

launch-dcos:
	cd .deploy; \
	terraform apply -var-file desired_cluster_profile

kubectl-config:
	kubectl config set-cluster dcos-k8s --server=http://localhost:9000
	kubectl config set-context dcos-k8s --cluster=dcos-k8s --namespace=default
	kubectl config use-context dcos-k8s

kubectl-tunnel:
	$(call get_master_ip)
	ssh -4 -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval=120" \
		-N -L 9000:apiserver-insecure.kubernetes.l4lb.thisdcos.directory:9000 \
		$(SSH_USER)@$(MASTER_IP)

ui:
	$(call get_master_lb_ip)
	open https://$(MASTER_LB_IP)

plan: plan-dcos

deploy: launch-dcos setup-cli install

upgrade-infra: launch-dcos

upgrade-dcos:
	cd .deploy; \
	terraform apply -var-file desired_cluster_profile.tfvars -var state=upgrade -target null_resource.bootstrap -target null_resource.master -parallelism=1; \
	terraform apply -var-file desired_cluster_profile.tfvars -var state=upgrade

destroy-dcos:
	$(RM) $(MASTER_IP_FILE)
	$(RM) $(MASTER_LB_IP_FILE)
	cd .deploy; \
	terraform destroy -var-file desired_cluster_profile

clean:
	$(RM) -r .deploy

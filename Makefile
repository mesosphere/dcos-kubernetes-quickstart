.PHONY: azure aws gce uninstall install get-cli setup-cli get-master-ip get-master-elb_ip plan-dcos launch-dcos detroy-dcos kubectl-config kubectl-tunnel plan deploy

RM := rm -f
SSH_USER := core
MASTER_IP_FILE := .master_ip
MASTER_ELB_IP_FILE := .master_elb_ip
TERRAFORM_INSTALLER_URL := github.com/dcos/terraform-dcos
DCOS_CLI_VERSION := 0.5.7
KUBERNETES_VERSION := v1.7.10

get-cli:
	$(eval export DCOS_CLI_VERSION)
	$(eval export KUBERNETES_VERSION)
	scripts/get_cli

azure: clean
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.azure desired_cluster_profile; \
	terraform init -from-module $(TERRAFORM_INSTALLER_URL)//azure

aws: clean
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.aws desired_cluster_profile; \
	terraform init -from-module $(TERRAFORM_INSTALLER_URL)//aws

gce: clean
	$(RM) -r .deploy
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.gce desired_cluster_profile; \
	terraform init -from-module $(TERRAFORM_INSTALLER_URL)//gcp; \
	rm desired_cluster_profile.tfvars.example

install:
	dcos package install --yes beta-kubernetes

uninstall:
	dcos package uninstall --yes beta-kubernetes

setup-cli:
	$(call get_master_ip)
	dcos cluster setup http://$(MASTER_IP)

get-master-ip:
	$(call get_master_ip)
	@echo $(MASTER_IP)

define get_master_ip
$(shell test -f $(MASTER_IP_FILE) || \
	terraform output -state=.deploy/terraform.tfstate "Mesos Master Public IP" | head -1 > $(MASTER_IP_FILE))
$(eval MASTER_IP := $(shell cat $(MASTER_IP_FILE)))
endef

get-master-elb-ip:
	$(call get_master_elb_ip)
	@echo $(MASTER_ELB_IP)

define get_master_elb_ip
$(shell test -f $(MASTER_ELB_IP_FILE) || \
	terraform output -state=.deploy/terraform.tfstate "Master ELB Address" > $(MASTER_ELB_IP_FILE))
$(eval MASTER_ELB_IP := $(shell cat $(MASTER_ELB_IP_FILE)))
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

plan: plan-dcos

deploy: launch-dcos setup-cli install

destroy-dcos:
	$(RM) $(MASTER_IP_FILE)
	$(RM) $(MASTER_ELB_IP_FILE)
	cd .deploy; \
	terraform destroy -var-file desired_cluster_profile

clean:
	$(RM) -r .deploy
	$(RM) dcos
	$(RM) kubectl

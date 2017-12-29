.PHONY: uninstall install setup-cli get-master-ip launch-dcos detroy-dcos docker-build docker kubectl-tunnel deploy

RM := rm -f
SSH_USER := core
MASTER_IP_FILE := .master_ip
DCOS_LAUNCH_VERSION := 0.5.7
KUBERNETES_VERSION := v1.7.10

azure: clean get-cli
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.azure desired_cluster_profile; \
	terraform init -from-module github.com/dcos/terraform-dcos//azure

aws: clean get-cli
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.aws desired_cluster_profile; \
	terraform init -from-module github.com/dcos/terraform-dcos//aws

gce: clean get-cli
	$(RM) -r .deploy
	mkdir .deploy
	cd .deploy; \
	cp ../resources/desired_cluster_profile.gce desired_cluster_profile; \
	terraform init -from-module github.com/dcos/terraform-dcos//gcp; \
	rm desired_cluster_profile.tfvars.example

get-cli:
	$(eval export DCOS_LAUNCH_VERSION)
	$(eval export KUBERNETES_VERSION)
	scripts/get_cli

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
	watch ./dcos task

destroy-dcos:
	$(RM) $(MASTER_IP_FILE)
	cd .deploy; \
	terraform destroy -var-file desired_cluster_profile

clean:
	$(RM) -r .deploy
	$(RM) dcos
	$(RM) kubectl

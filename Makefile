
RM := rm -f
SSH_USER := core
TERRAFORM_INSTALLER_URL := github.com/dcos/terraform-dcos
DCOS_VERSION := 1.11
KUBERNETES_VERSION ?= 1.10.4
KUBERNETES_FRAMEWORK_VERSION ?= 1.1.1-1.10.4

# Set PATH to include local dir for locally downloaded binaries.
export PATH := .:$(PATH)

# Get the path to relevant binaries.
DCOS_CMD := $(shell PATH=$(PATH) command -v dcos 2> /dev/null)
KUBECTL_CMD := $(shell PATH=$(PATH) command -v kubectl 2> /dev/null)
TERRAFORM_CMD := $(shell command -v terraform 2> /dev/null)
TERRAFORM_APPLY_ARGS ?=
TERRAFORM_DESTROY_ARGS ?=

UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
OPEN := xdg-open
else
OPEN := open
endif

# Define a new line character to use in error strings.
define n


endef

.PHONY: get-cli
get-cli:
	$(eval export DCOS_VERSION)
	$(eval export KUBERNETES_VERSION)
	scripts/get_cli

.PHONY: check-cli
check-cli: check-terraform check-dcos check-kubectl

.PHONY: check-terraform
check-terraform:
ifndef TERRAFORM_CMD
	$(error "$n$nNo terraform command in $(PATH).$n$nPlease install via 'brew install terraform' on MacOS, or download from https://www.terraform.io/downloads.html.$n$n")
endif

.PHONY: check-dcos
check-dcos:
ifndef DCOS_CMD
	$(error "$n$nNo dcos command in $(PATH).$n$nPlease run 'make get-cli' to download required binaries.$n$n")
endif

.PHONY: check-kubectl
check-kubectl:
ifndef KUBECTL_CMD
	$(error "$n$nNo kubectl command in $(PATH).$n$nPlease run 'make get-cli' to download required binaries.$n$n")
endif

.PHONY: azure
azure: clean check-terraform
	mkdir .deploy
	cd .deploy; \
	$(TERRAFORM_CMD) init -from-module $(TERRAFORM_INSTALLER_URL)/azure; \
	cp ../resources/desired_cluster_profile.azure desired_cluster_profile; \
	cp ../resources/options.json.azure options.json; \
	cp ../resources/override.azure.tf override.tf; \
	cp ../resources/kubeapi-proxy.json .;\
 	../scripts/kubeapi-proxy-azure.sh

.PHONY: aws
aws: clean check-terraform
	mkdir .deploy
	cd .deploy; \
	$(TERRAFORM_CMD) init -from-module $(TERRAFORM_INSTALLER_URL)/aws; \
	cp ../resources/desired_cluster_profile.aws desired_cluster_profile; \
	cp ../resources/options.json.aws options.json; \
	cp ../resources/override.aws.tf override.tf; \
	cp ../resources/kubeapi-proxy.json .;\
	../scripts/kubeapi-proxy-aws.sh

.PHONY: gcp
gcp: clean check-terraform
	mkdir .deploy
	cd .deploy; \
	$(TERRAFORM_CMD) init -from-module $(TERRAFORM_INSTALLER_URL)/gcp; \
	cp ../resources/desired_cluster_profile.gcp desired_cluster_profile; \
	cp ../resources/options.json.gcp options.json; \
	cp ../resources/override.gcp.tf override.tf; \
	cp ../resources/kubeapi-proxy.json .; \
	../scripts/kubeapi-proxy-gcp.sh

.PHONY: get-master-lb-ip
get-master-lb-ip: check-terraform
	$(call get_master_lb_ip)
	@echo $(MASTER_LB_IP)

define get_master_lb_ip
$(eval MASTER_LB_IP := $(shell $(TERRAFORM_CMD) output -state=.deploy/terraform.tfstate "Master ELB Public IP"))
endef

.PHONY: get-public-agent-ip
get-public-agent-ip: check-terraform
	$(call get_public_agent_ip)
	@echo $(PUBLIC_AGENT_IP)

define get_public_agent_ip
$(eval PUBLIC_AGENT_IP := $(shell $(TERRAFORM_CMD) output -state=.deploy/terraform.tfstate  "Public Agent Public IPs" | head -1 | cut -f 1 -d ','))
endef

.PHONY: plan-dcos
plan-dcos: check-terraform
	cd .deploy; \
	$(TERRAFORM_CMD) plan -var-file desired_cluster_profile

.PHONY: launch-dcos
launch-dcos: check-terraform
	cd .deploy; \
	$(TERRAFORM_CMD) apply $(TERRAFORM_APPLY_ARGS) -var-file desired_cluster_profile

.PHONY: plan
plan: plan-dcos

.PHONY: deploy
deploy: check-cli launch-dcos setup-cli install

.PHONY: setup-cli
setup-cli: check-dcos
	$(call get_master_lb_ip)
	$(DCOS_CMD) cluster setup https://$(MASTER_LB_IP)
	@scripts/poll_api.sh "DC/OS Master" $(MASTER_LB_IP) 443

.PHONY: ui
ui:
	$(call get_master_lb_ip)
	$(OPEN) https://$(MASTER_LB_IP)

.PHONY: install
install: check-dcos
	$(DCOS_CMD) package install --yes marathon-lb;\
	$(DCOS_CMD) package install --yes kubernetes --package-version=$(KUBERNETES_FRAMEWORK_VERSION) --options=./.deploy/options.json;\
	$(DCOS_CMD) marathon app add ./.deploy/kubeapi-proxy.json

.PHONY: watch
watch:
	watch dcos kubernetes plan show deploy

.PHONY: kubeconfig
kubeconfig:
	$(call get_public_agent_ip)
	$(DCOS_CMD) kubernetes kubeconfig --apiserver-url https://$(PUBLIC_AGENT_IP):6443 --insecure-skip-tls-verify
	@scripts/poll_api.sh "Kubernetes API" $(PUBLIC_AGENT_IP) 6443

.PHONY: upgrade-infra
upgrade-infra: launch-dcos

.PHONY: upgrade-dcos
upgrade-dcos: check-terraform
	cd .deploy; \
	$(TERRAFORM_CMD) apply -var-file desired_cluster_profile.tfvars -var state=upgrade -target null_resource.bootstrap -target null_resource.master -parallelism=1; \
	$(TERRAFORM_CMD) apply -var-file desired_cluster_profile.tfvars -var state=upgrade

.PHONY: uninstall
uninstall: check-dcos
	$(DCOS_CMD) package uninstall --yes marathon-lb; \
	$(DCOS_CMD) package uninstall --yes kubernetes; \
	$(DCOS_CMD) marathon app remove kubeapi-proxy

.PHONY: destroy
destroy: check-terraform
	cd .deploy; \
	$(TERRAFORM_CMD) destroy $(TERRAFORM_DESTROY_ARGS) -var-file desired_cluster_profile

.PHONY: clean
clean:
	$(RM) -r .deploy dcos kubectl

.PHONY: kubectl-tunnel
kubectl-tunnel:
	$(KUBECTL_CMD) config set-cluster dcos-k8s --server=http://localhost:9000
	$(KUBECTL_CMD) config set-context dcos-k8s --cluster=dcos-k8s --namespace=default
	$(KUBECTL_CMD) config use-context dcos-k8s
	$(call get_public_agent_ip)
	ssh -4 -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval=120" \
		-N -L 9000:apiserver-insecure.kubernetes.l4lb.thisdcos.directory:9000 \
		$(SSH_USER)@$(PUBLIC_AGENT_IP)
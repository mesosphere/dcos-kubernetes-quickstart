
RM := rm -f
SSH_USER := core
TERRAFORM_INSTALLER_URL := github.com/dcos/terraform-dcos
DCOS_VERSION := 1.12
CUSTOM_DCOS_DOWNLOAD_PATH := https://downloads.dcos.io/dcos/stable/1.12.0/dcos_generate_config.sh
KUBERNETES_VERSION ?= 1.13.2
KUBERNETES_FRAMEWORK_VERSION ?= 2.1.0-1.12.3
# PATH_TO_PACKAGE_OPTIONS holds the path to the package options file to be used
# when installing DC/OS Kubernetes.
PATH_TO_PACKAGE_OPTIONS ?= "$(PWD)/.deploy/options.json"

# Set PATH (locally) to include local dir for locally downloaded binaries.
FAKEPATH := "$(PWD):$(PATH)"

# Get the path to relevant binaries.
DCOS_CMD := $(shell PATH=$(FAKEPATH) command -v dcos 2> /dev/null)
KUBECTL_CMD := $(shell PATH=$(FAKEPATH) command -v kubectl 2> /dev/null)
TERRAFORM_CMD := $(shell PATH=$(FAKEPATH) command -v terraform 2> /dev/null)
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
	$(error "$n$nNo terraform command in $(FAKEPATH).$n$nPlease install via 'brew install terraform' on MacOS, or download from https://www.terraform.io/downloads.html.$n$n")
endif

.PHONY: check-dcos
check-dcos:
ifndef DCOS_CMD
	$(error "$n$nNo dcos command in $(FAKEPATH).$n$nPlease run 'make get-cli' to download required binaries.$n$n")
endif

.PHONY: check-kubectl
check-kubectl:
ifndef KUBECTL_CMD
	$(error "$n$nNo kubectl command in $(FAKEPATH).$n$nPlease run 'make get-cli' to download required binaries.$n$n")
endif

.PHONY: azure
azure: clean check-terraform
	mkdir .deploy
	cd .deploy; \
	$(TERRAFORM_CMD) init -from-module $(TERRAFORM_INSTALLER_URL)/azure; \
	sed 's@CUSTOM_DCOS_DOWNLOAD_PATH@'"$(CUSTOM_DCOS_DOWNLOAD_PATH)"'@g' ../resources/desired_cluster_profile.azure > desired_cluster_profile; \
	cp ../resources/options.json.azure options.json; \
	cp ../resources/override.azure.tf override.tf; \
	cp ../resources/kubeapi-proxy.json .;\
 	../scripts/kubeapi-proxy-azure.sh

.PHONY: aws
aws: clean check-terraform
	mkdir .deploy
	cd .deploy; \
	$(TERRAFORM_CMD) init -from-module $(TERRAFORM_INSTALLER_URL)/aws; \
	sed 's@CUSTOM_DCOS_DOWNLOAD_PATH@'"$(CUSTOM_DCOS_DOWNLOAD_PATH)"'@g' ../resources/desired_cluster_profile.aws > desired_cluster_profile; \
	cp ../resources/options.json.aws options.json; \
	cp ../resources/override.aws.tf override.tf; \
	cp ../resources/kubeapi-proxy.json .;\
	../scripts/kubeapi-proxy-aws.sh

.PHONY: gcp
gcp: clean check-terraform
	mkdir .deploy
	cd .deploy; \
	$(TERRAFORM_CMD) init -from-module $(TERRAFORM_INSTALLER_URL)/gcp; \
	sed 's@CUSTOM_DCOS_DOWNLOAD_PATH@'"$(CUSTOM_DCOS_DOWNLOAD_PATH)"'@g' ../resources/desired_cluster_profile.gcp > desired_cluster_profile; \
	cp ../resources/options.json.gcp options.json; \
	cp ../resources/override.gcp.tf override.tf; \
	cp ../resources/kubeapi-proxy.json .; \
	../scripts/kubeapi-proxy-gcp.sh

.PHONY: get-master-lb-ip
get-master-lb-ip: check-terraform
	$(call get_master_lb_ip)
	@echo $(MASTER_LB_IP)

define get_master_lb_ip
$(eval MASTER_LB_IP := $(shell $(TERRAFORM_CMD) output -state=.deploy/terraform.tfstate "Master Load Balancer Public IP"))
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
	@cd .deploy; \
	$(TERRAFORM_CMD) plan -var-file desired_cluster_profile

.PHONY: launch-dcos
launch-dcos: check-terraform
	@cd .deploy; \
	$(TERRAFORM_CMD) apply $(TERRAFORM_APPLY_ARGS) -var-file desired_cluster_profile

.PHONY: plan
plan: plan-dcos

.PHONY: deploy
deploy: check-cli launch-dcos setup-cli install

.PHONY: setup-cli
setup-cli: check-dcos
	$(call get_master_lb_ip)
	for i in {1..10}; do $(DCOS_CMD) cluster setup https://$(MASTER_LB_IP) --insecure && break || (sleep 3) ; done
	@scripts/poll_api.sh "DC/OS Master" $(MASTER_LB_IP) 443

.PHONY: ui
ui:
	$(call get_master_lb_ip)
	$(OPEN) https://$(MASTER_LB_IP)

KUBERNETES_CLUSTER_STUB_URL := https://universe-converter.mesosphere.com/transform?url=https://infinity-artifacts.s3.amazonaws.com/permanent/kubernetes-cluster/assets/63eaa87/stub-universe-kubernetes-cluster.json
.PHONY: install
install: check-dcos
	@echo "Installing Mesosphere Kubernetes Engine..."
	$(DCOS_CMD) package install --yes kubernetes --package-version="$(KUBERNETES_FRAMEWORK_VERSION)"
	@echo "Waiting for Mesosphere Kubernetes Engine to be up..."
	@while [[ ! $$($(DCOS_CMD) kubernetes manager plan show deploy 2> /dev/null | head -n1 | grep COMPLETE ) ]]; do \
		sleep 1; \
	done
	@echo "Adding stub URL"
	$(DCOS_CMD) package repo add --index=0 kubernetes-cluster-aws "$(KUBERNETES_CLUSTER_STUB_URL)"
	@echo "Creating a Kubernetes cluster..."
	$(DCOS_CMD) kubernetes cluster create --yes --options="$(PATH_TO_PACKAGE_OPTIONS)"

.PHONY: marathon-lb
marathon-lb:
	$(DCOS_CMD) package install --yes marathon-lb
	@sleep 30
	$(DCOS_CMD) marathon app add "$(PWD)/.deploy/kubeapi-proxy.json"

.PHONY: watch-kubernetes-cluster
watch-kubernetes-cluster:
	watch dcos kubernetes cluster debug --cluster-name=dev/kubernetes01 plan show deploy

.PHONY: watch-kubernetes
watch-kubernetes:
	watch dcos kubernetes manager plan show deploy

.PHONY: kubeconfig
kubeconfig:
	$(call get_public_agent_ip)
	$(DCOS_CMD) kubernetes cluster kubeconfig --cluster-name dev/kubernetes01 --apiserver-url https://$(PUBLIC_AGENT_IP):6443 --context-name devkubernetes01 --insecure-skip-tls-verify
	@scripts/poll_api.sh "Kubernetes API" $(PUBLIC_AGENT_IP) 6443

.PHONY: aws-csi-driver
aws-csi-driver:
	wget https://github.com/mesosphere/csi-driver-deployments/archive/master.zip -O csi-driver-deployments.zip
	unzip csi-driver-deployments.zip && rm csi-driver-deployments.zip
	$(KUBECTL_CMD) apply -f csi-driver-deployments-master/aws-ebs/kubernetes/latest
	@scripts/poll_aws_csi.sh
	rm -rf csi-driver-deployments-master

E2E_REPO := "git@github.com:kubernetes-sigs/aws-ebs-csi-driver.git"
.PHONY: aws-csi-e2e
aws-csi-e2e:
	wget https://github.com/kubernetes-sigs/aws-ebs-csi-driver/archive/master.zip -O aws-ebs-csi-driver.zip
	unzip aws-ebs-csi-driver.zip && rm aws-ebs-csi-driver.zip
	cd aws-ebs-csi-driver-master && KUBECONFIG=~/.kube/config make test-e2e
	rm -rf aws-ebs-csi-driver-master

.PHONY: upgrade-infra
upgrade-infra: launch-dcos

.PHONY: upgrade-dcos
upgrade-dcos: check-terraform
	cd .deploy; \
	$(TERRAFORM_CMD) apply -var-file desired_cluster_profile.tfvars -var state=upgrade -target null_resource.bootstrap -target null_resource.master -parallelism=1; \
	$(TERRAFORM_CMD) apply -var-file desired_cluster_profile.tfvars -var state=upgrade

.PHONY: uninstall
uninstall: check-dcos
	$(DCOS_CMD) marathon app remove kubeapi-proxy
	$(DCOS_CMD) package uninstall marathon-lb --yes
	$(DCOS_CMD) kubernetes cluster delete --cluster-name dev/kubernetes01 --yes
	for i in {1..8}; do ! $(DCOS_CMD) marathon app list --json | jq '.[].id' | grep '/dev/kubernetes01' >/dev/null && break || (echo "Kubernetes Cluster is still uninstalling. Retrying in 15 seconds..." && sleep 15) ; done
	$(DCOS_CMD) package uninstall kubernetes --yes
	for i in {1..8}; do ! $(DCOS_CMD) marathon app list --json | jq '.[].id' | grep '/kubernetes' >/dev/null && break || (echo "Mesosphere Kubernetes Engine is still uninstalling. Retrying in 15 seconds..." && sleep 15) ; done
	$(DCOS_CMD) package repo remove kubernetes-cluster-aws

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
		-N -L 9000:apiserver-insecure.devkubernetes01.l4lb.thisdcos.directory:9000 \
		$(SSH_USER)@$(PUBLIC_AGENT_IP)

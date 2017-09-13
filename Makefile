.PHONY: uninstall install setup-cli get-master-ip launch-dcos detroy-dcos docker-build docker kubectl-tunnel install-kube-dns deploy

RM := rm -f
LAUNCH_CONFIG_FILE := launch.yaml
CLUSTER_INFO_FILE := cluster_info.json
BUILD_FILE := .output
MASTER_IP_FILE := .master_ip
ID_FILE := .id_key
SSH_USER := core
DCOS_INSTALLER_URL := https://downloads.dcos.io/dcos/stable/1.10.0/dcos_generate_config.sh


install:
	dcos package install --yes beta-kubernetes


uninstall:
	dcos package uninstall --yes beta-kubernetes


DCOS_USERNAME := bootstrapuser
DCOS_PASSWORD := deleteme
setup-cli: kubectl-config
	$(call get_master_ip)
	dcos cluster setup http://$(MASTER_IP)

kubectl-config:
	kubectl config set-cluster dcos-k8s --server=http://localhost:9000
	kubectl config set-context dcos-k8s --cluster=dcos-k8s --namespace=default
	kubectl config use-context dcos-k8s

get-master-ip:
	$(call get_master_ip)
	@echo $(MASTER_IP)

define get_master_ip
$(shell test -f $(MASTER_IP_FILE) || \
	dcos-launch describe | jq '.["masters"] | .[] | .["public_ip"]' | head -1 | sed s/\"//g > $(MASTER_IP_FILE))
$(eval MASTER_IP := $(shell cat $(MASTER_IP_FILE)))
endef

launch-dcos: $(CLUSTER_INFO_FILE)
	dcos-launch wait

$(CLUSTER_INFO_FILE): $(LAUNCH_CONFIG_FILE)
	dcos-launch create -c $(LAUNCH_CONFIG_FILE)

$(ID_FILE): $(CLUSTER_INFO_FILE)
	cat $(CLUSTER_INFO_FILE) | jq '{ssh_private_key} | .ssh_private_key' | sed 's/\\n/\n/g' | sed 's/"//g' > $(ID_FILE)
	chmod 400 $(ID_FILE)

$(LAUNCH_CONFIG_FILE):
ifeq ($(PLATFORM), aws)
	$(eval export LAUNCH_CONFIG_AWS)
	@echo "$$LAUNCH_CONFIG_AWS" > $@
    $(eval SSH_USER := centos)
else
	$(eval export LAUNCH_CONFIG_GCE)
	@echo "$$LAUNCH_CONFIG_GCE" > $@
endif


destroy-dcos:
	dcos-launch delete
	$(RM) $(CLUSTER_INFO_FILE)
	$(RM) $(LAUNCH_CONFIG_FILE)
	$(RM) $(MASTER_IP_FILE)
	$(RM) $(ID_FILE)

define rand_name
$(shell cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
endef

define LAUNCH_CONFIG_GCE
---
launch_config_version: 1
deployment_name: dcos-cluster-$(call rand_name)
installer_url: $(DCOS_INSTALLER_URL)
platform: gce
provider: onprem
os_name: coreos
source_image: coreos-stable-1465-6-0-v20170817
machine_type: n1-standard-8
dcos_config:
    cluster_name: k8s-dev
    resolvers:
        - 169.254.169.254
    dns_search: c.massive-bliss-781.internal google.internal
    master_discovery: static
    dns_forward_zones:
    - - "cluster.local"
      - - - "10.100.0.10"
          - 53
num_masters: $(NUM_MASTERS)
num_private_agents: $(NUM_PRIVATE_AGENTS)
num_public_agents: $(NUM_PUBLIC_AGENTS)
ssh_user: core
key_helper: true
gce_zone: us-west1-b
disable_updates: true
endef

define LAUNCH_CONFIG_AWS
---
launch_config_version: 1
deployment_name: dcos-cluster-$(call rand_name)
installer_url: $(DCOS_INSTALLER_URL)
provider: onprem
platform: aws
key_helper: true
num_masters: $(NUM_MASTERS)
num_private_agents: $(NUM_PRIVATE_AGENTS)
num_public_agents: $(NUM_PUBLIC_AGENTS)
os_name: cent-os-7-dcos-prereqs
aws_region: us-west-2
instance_type: m4.2xlarge
dcos_config:
    cluster_name: k8s-dev
    master_discovery: static
    rexray_config_preset: aws
    resolvers:
        - 8.8.8.8
        - 8.8.4.4
    dns_forward_zones:
    - - "cluster.local"
      - - - "10.100.0.10"
          - 53
endef


kubectl-tunnel: $(ID_FILE)
	$(call get_master_ip)
	ssh -i $(ID_FILE) -f -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval=120" \
		 -N -L 9000:apiserver-insecure.kubernetes.l4lb.thisdcos.directory:9000 \
		$(SSH_USER)@$(MASTER_IP)

docker-build:
	docker build -t mesosphere/dcos-kubernetes .

GOOGLE_APPLICATION_CREDS := $(if ${GOOGLE_APPLICATION_CREDENTIALS},${GOOGLE_APPLICATION_CREDENTIALS},credentials.json)
NUM_PRIVATE_AGENTS := $(if ${NUM_PRIVATE_AGENTS},${NUM_PRIVATE_AGENTS},3)
NUM_PUBLIC_AGENTS := $(if ${NUM_PUBLIC_AGENTS},${NUM_PUBLIC_AGENTS},1)
NUM_MASTERS := $(if ${NUM_MASTERS},${NUM_MASTERS},1)
define docker_container
	docker run -i \
		-v $(GOOGLE_APPLICATION_CREDS):/credentials.json \
		-e GOOGLE_APPLICATION_CREDENTIALS=/credentials.json \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e NUM_PRIVATE_AGENTS=${NUM_PRIVATE_AGENTS} \
		-e NUM_PUBLIC_AGENTS=${NUM_PUBLIC_AGENTS} \
		-e NUM_MASTERS=${NUM_MASTERS} \
		-v $(PWD):/dcos-kubernetes \
		$(2) mesosphere/dcos-kubernetes $(1)
endef

docker:
	$(call docker_container, /bin/bash, -t)


deploy: docker dcos-launch setup-cli install

install-kube-dns: kubectl-config
	kubectl create -f add-ons/dns/kubedns-cm.yaml
	kubectl create -f add-ons/dns/kubedns-svc.yaml
	kubectl create -f add-ons/dns/kubedns-deployment.yaml

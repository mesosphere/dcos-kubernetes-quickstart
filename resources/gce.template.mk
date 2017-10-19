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

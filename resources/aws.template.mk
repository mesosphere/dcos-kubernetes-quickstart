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

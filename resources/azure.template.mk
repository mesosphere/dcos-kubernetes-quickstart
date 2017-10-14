define LAUNCH_CONFIG_AZURE
---
launch_config_version: 1
deployment_name: dcos-cluster-$(call rand_name)
template_url: https://downloads.dcos.io/dcos/testing/master/commit/21932d9f3c8cef0b48086e7c969e67eb41940d0c/azure/acs-1master.azuredeploy.json
provider: azure
azure_location: East US 2
key_helper: true
template_parameters:
    masterEndpointDNSNamePrefix: dcos-$(call rand_name)-master
    agentEndpointDNSNamePrefix: dcos-$(call rand_name)-agent
    linuxAdminUsername: dcos
    agentVMSize: Standard_D4_v2
    agentCount: $(NUM_PRIVATE_AGENTS)
    nameSuffix: 123
    enableVMDiagnostics: false
    oauthEnabled: "true"
ssh_user: dcos
endef

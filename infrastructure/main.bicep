targetScope = 'subscription'

@description('Azure region used for all project resources.')
param location string = 'canadacentral'

@description('Name of the resource group.')
param resourceGroupName string = 'rg-monitoring-incident-dev'

@description('Environment represented by this deployment.')
@allowed([
  'Development'
  'Test'
])
param environment string = 'Development'

@description('GitHub username or project owner.')
param owner string = 'ShivamP63'

@description('Linux VM administrator username.')
param adminUsername string = 'azureadmin'

@description('SSH public key used to authenticate to the Linux VM.')
param adminSshPublicKey string

@description('Public IPv4 address allowed to connect to the VM over SSH.')
param allowedSshSource string

@description('Linux VM size.')
param vmSize string = 'Standard_D2s_v3'

var commonTags = {
  Environment: environment
  Owner: owner
  Project: 'Azure VM Monitoring and Incident Response'
  ManagedBy: 'Bicep'
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: commonTags
}

module networking 'modules/networking.bicep' = {
  name: 'deploy-networking'
  scope: resourceGroup
  params: {
    location: location
    allowedSshSource: allowedSshSource
    tags: commonTags
  }
}

module virtualMachine 'modules/virtual-machine.bicep' = {
  name: 'deploy-virtual-machine'
  scope: resourceGroup
  params: {
    location: location
    subnetId: networking.outputs.subnetId
    adminUsername: adminUsername
    adminSshPublicKey: adminSshPublicKey
    vmSize: vmSize
    tags: commonTags
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'deploy-monitoring'
  scope: resourceGroup
  params: {
    location: location
    vmName: virtualMachine.outputs.vmName
    tags: commonTags
  }
}

output deployedResourceGroupName string = resourceGroup.name
output vmName string = virtualMachine.outputs.vmName
output vmPublicIpAddress string = virtualMachine.outputs.publicIpAddress
output logAnalyticsWorkspaceName string = monitoring.outputs.workspaceName
output dataCollectionRuleName string = monitoring.outputs.dataCollectionRuleName
output sshCommand string = 'ssh ${adminUsername}@${virtualMachine.outputs.publicIpAddress}'
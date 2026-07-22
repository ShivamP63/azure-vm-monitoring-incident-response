@description('Azure region used for networking resources.')
param location string

@description('Public IPv4 address allowed to connect over SSH.')
param allowedSshSource string

@description('Tags applied to project resources.')
param tags object

var virtualNetworkName = 'vnet-monitoring-dev'
var subnetName = 'snet-monitoring-dev'
var networkSecurityGroupName = 'nsg-monitoring-vm-dev'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-From-Admin'
        properties: {
          description: 'Allow SSH only from the project administrator public IP address.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: allowedSshSource
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.30.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.30.1.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

output virtualNetworkName string = virtualNetwork.name
output networkSecurityGroupName string = networkSecurityGroup.name
output subnetId string = virtualNetwork.properties.subnets[0].id
@description('Azure region used for monitoring resources.')
param location string

@description('Name of the Linux VM being monitored.')
param vmName string

@description('Tags applied to project resources.')
param tags object

var workspaceName = 'law-monitoring-incident-dev'
var dataCollectionRuleName = 'dcr-monitoring-linux-dev'
var dataCollectionAssociationName = 'dcr-association-monitoring-linux'

resource linuxVm 'Microsoft.Compute/virtualMachines@2024-07-01' existing = {
  name: vmName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: dataCollectionRuleName
  location: location
  tags: tags
  kind: 'Linux'
  properties: {
    description: 'Collects Linux VM performance counters for monitoring and incident investigation.'
    dataSources: {
      performanceCounters: [
        {
          name: 'linuxPerformanceCounters'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\Processor(*)\\% Processor Time'
            '\\Memory\\Available MBytes'
            '\\Memory\\% Used Memory'
            '\\Logical Disk(*)\\% Free Space'
            '\\Logical Disk(*)\\Disk Reads/sec'
            '\\Logical Disk(*)\\Disk Writes/sec'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'logAnalyticsDestination'
          workspaceResourceId: logAnalyticsWorkspace.id
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
        ]
        destinations: [
          'logAnalyticsDestination'
        ]
      }
    ]
  }
}

resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = {
  scope: linuxVm
  name: dataCollectionAssociationName
  properties: {
    description: 'Associates the monitoring DCR with the project Linux VM.'
    dataCollectionRuleId: dataCollectionRule.id
  }
}

output workspaceName string = logAnalyticsWorkspace.name
output workspaceId string = logAnalyticsWorkspace.id
output dataCollectionRuleName string = dataCollectionRule.name
output dataCollectionRuleId string = dataCollectionRule.id
output associationName string = dataCollectionRuleAssociation.name
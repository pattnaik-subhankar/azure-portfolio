param location string
param namePrefix string
param logAnalyticsWorkspaceId string
param tags object

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: 'evhns-${namePrefix}'
  location: location
  sku: { name: 'Standard' tier: 'Standard' capacity: 1 }
  tags: tags
  properties: {
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: '1.2'
    disableLocalAuth: true
  }
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: 'sbns-${namePrefix}'
  location: location
  sku: { name: 'Premium' tier: 'Premium' capacity: 1 }
  tags: tags
  properties: {
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: '1.2'
    disableLocalAuth: true
  }
}

resource diagnosticEventHubs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-law'
  scope: eventHubNamespace
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [ { categoryGroup: 'allLogs' enabled: true } ]
    metrics: [ { category: 'AllMetrics' enabled: true } ]
  }
}

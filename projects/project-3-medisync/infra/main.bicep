targetScope = 'resourceGroup'

@description('Azure region for the reference environment.')
param location string = resourceGroup().location
@description('Environment name, for example dev or prod.')
param environment string
@description('Globally unique, lowercase workload prefix supplied by deployment automation.')
param namePrefix string
@description('Tags required by the workload governance standard.')
param tags object = {}

module observability './modules/monitoring.bicep' = {
  name: 'monitoring-${environment}'
  params: { location: location namePrefix: namePrefix tags: tags }
}

module messaging './modules/messaging.bicep' = {
  name: 'messaging-${environment}'
  params: {
    location: location
    namePrefix: namePrefix
    logAnalyticsWorkspaceId: observability.outputs.workspaceId
    tags: tags
  }
}

// Private endpoints, DNS zone groups, CMK and application identities are kept
// as deployment-time modules after the approved landing-zone/DNS design exists.
// This reference intentionally creates no public endpoint or secret material.

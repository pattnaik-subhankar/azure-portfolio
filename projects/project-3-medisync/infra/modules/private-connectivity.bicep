@description('Existing private endpoint subnet ID supplied by the approved landing zone.')
param privateEndpointSubnetId string
@description('Name of the pre-approved private DNS zone for the target service.')
param privateDnsZoneId string
@description('Private Link resource ID of the target service.')
param privateLinkServiceId string
@description('Target subresource, for example namespace or Sql.')
param groupId string
@description('Name for this private endpoint.')
param privateEndpointName string
@description('Deployment location.')
param location string

resource endpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: { id: privateEndpointSubnetId }
    privateLinkServiceConnections: [
      {
        name: 'resource-connection'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [ groupId ]
        }
      }
    ]
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: endpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      { name: 'approved-zone' properties: { privateDnsZoneId: privateDnsZoneId } }
    ]
  }
}

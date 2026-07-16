/*
  ShopFlow — API Management Bicep Module
  Standard v2, VNet integration, product definitions (Partner, Internal).
*/
param location string
param environment string
param apimName string = 'apim-shopflow-${environment}-${uniqueString(resourceGroup().id)}'

resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apimName
  location: location
  sku: {
    name: environment == 'prod' ? 'StandardV2' : 'Developer'
    capacity: 1
  }
  identity: { type: 'SystemAssigned' }
  properties: {
    publisherEmail: 'admin@shopflow.io'
    publisherName: 'ShopFlow'
    virtualNetworkType: 'External'
  }
}

resource apimApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apim
  name: 'shopflow-orders-v1'
  properties: {
    displayName: 'Orders API v1'
    path: 'orders'
    protocols: ['https']
    subscriptionRequired: true
  }
}

resource apimProductPartner 'Microsoft.ApiManagement/service/products@2023-05-01-preview' = {
  parent: apim
  name: 'partner-access'
  properties: {
    displayName: 'Partner Access'
    description: 'Order and inventory APIs for delivery partners'
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 50
  }
}

resource apimProductInternal 'Microsoft.ApiManagement/service/products@2023-05-01-preview' = {
  parent: apim
  name: 'internal-channel'
  properties: {
    displayName: 'Internal Channel'
    description: 'For internal consumer apps'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 20
  }
}

output apimId string = apim.id
output apimName string = apim.name
output gatewayUrl string = apim.properties.gatewayUrl

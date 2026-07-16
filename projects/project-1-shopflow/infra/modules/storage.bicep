/*
  ShopFlow — Storage Account Bicep Module
  Blob storage for audit logs with immutability policy.
*/
param location string
param environment string
param accountName string = 'stoshopflow${environment}${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: toLower(accountName)
  location: location
  kind: 'StorageV2'
  sku: {
    name: environment == 'prod' ? 'Standard_ZRS' : 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: { defaultAction: 'Deny', bypass: 'AzureServices' }
  }
}

resource auditContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccount::blobServices
  name: 'order-audit'
}

resource immutabilityPolicy 'Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies@2023-01-01' = if (environment == 'prod') {
  parent: auditContainer
  name: 'default'
  properties: {
    immutabilityPeriodSinceCreationInDays: 365
    allowProtectedAppendWrites: true
  }
}

output accountName string = storageAccount.name
output accountId string = storageAccount.id
output auditContainerName string = auditContainer.name

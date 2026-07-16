/*
  ShopFlow — Function App Bicep Module
  Premium plan, VNet integration, App Insights connected, Key Vault references.
*/
param location string
param environment string
param appName string
@description('App Service Plan (Premium EP1) resource ID')
param planId string
param keyVaultId string
param appSettings map = {}
param serviceBusConnectionString_secretName string = 'ServiceBusConnectionString'

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  kind: 'functionapp,linux'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: planId
    siteConfig: {
      applicationInsightsConnectionString: '@Microsoft.KeyVault(SecretUri=${keyVaultId}/secrets/ApplicationInsightsConnectionString/)'
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        { name: 'AzureWebJobsStorage__accountName', value: 'sto${uniqueString(appName)}' }
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'dotnet-isolated' }
        { name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING', value: '@Microsoft.KeyVault(SecretUri=${keyVaultId}/secrets/AzureWebJobsStorage/)' }
      ]
    }
  }
}

output appId string = functionApp.id
output appName string = functionApp.name
output systemIdentityPrincipalId string = functionApp.identity.principalId

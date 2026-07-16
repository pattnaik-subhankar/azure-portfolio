/*
  Author:       Subhankar Pattnaik
  Project:      ShopFlow — E-Commerce API Modernization Platform
  Description:  Main Bicep orchestrator. Deploys all modules via parameterized environment files.
*/

@description('Environment name (dev / prod)')
param environment string = 'dev'

@description('Azure region')
param location string = resourceGroup().location

@description('SQL admin login')
param sqlAdminLogin string

@description('SQL admin password (Key Vault reference in prod)')
@secure()
param sqlAdminPassword string

// ── Key Vault ──────────────────────────────────────────────────────────
module keyVault './modules/key-vault.bicep' = {
  name: 'kv-shopflow-${environment}'
  params: {
    location: location
    environment: environment
  }
}

// ── Storage ────────────────────────────────────────────────────────────
module storage './modules/storage.bicep' = {
  name: 'sto-shopflow-${environment}'
  params: {
    location: location
    environment: environment
  }
}

// ── Service Bus ─────────────────────────────────────────────────────────
module serviceBus './modules/service-bus.bicep' = {
  name: 'sb-shopflow-${environment}'
  params: {
    location: location
    environment: environment
  }
}

// ── Azure SQL ──────────────────────────────────────────────────────────
module sql './modules/sql.bicep' = {
  name: 'sql-shopflow-${environment}'
  params: {
    location: location
    environment: environment
    adminLogin: sqlAdminLogin
    adminPassword: sqlAdminPassword
  }
}

// ── API Management ──────────────────────────────────────────────────────
module apim './modules/apim.bicep' = {
  name: 'apim-shopflow-${environment}'
  params: {
    location: location
    environment: environment
    subnetId: requires('vnet-subnet-id') // Provided by networking or via param
  }
}

// ── Function Apps (Orders + Catalog) ──────────────────────────────────
module ordersApi './modules/function-app.bicep' = {
  name: 'func-orders-${environment}'
  params: {
    location: location
    environment: environment
    appName: 'func-shopflow-orders-${environment}'
    planId: requires('plan-id') // EP plan shared across Functions
    keyVaultId: keyVault.outputs.vaultId
    serviceBusConnectionString_secretName: 'ServiceBusConnectionString'
  }
}

module catalogApi './modules/function-app.bicep' = {
  name: 'func-catalog-${environment}'
  params: {
    location: location
    environment: environment
    appName: 'func-shopflow-catalog-${environment}'
    planId: requires('plan-id')
    keyVaultId: keyVault.outputs.vaultId
  }
}

// ── Fulfillment Processor ───────────────────────────────────────────────
module fulfillmentProcessor './modules/function-app.bicep' = {
  name: 'func-fulfillment-${environment}'
  params: {
    location: location
    environment: environment
    appName: 'func-shopflow-fulfillment-${environment}'
    planId: requires('plan-id')
    keyVaultId: keyVault.outputs.vaultId
  }
}

// ── Front Door + WAF ────────────────────────────────────────────────────
module frontDoor './modules/front-door.bicep' = {
  name: 'fd-shopflow-${environment}'
  params: {
    location: location
    environment: environment
    apimFqdn: apim.outputs.gatewayUrl
  }
}

// ── Monitoring (App Insights + Log Analytics) ─────────────────────────
module monitoring './modules/monitoring.bicep' = {
  name: 'mon-shopflow-${environment}'
  params: {
    location: location
    environment: environment
    functionAppIds: [
      ordersApi.outputs.appId
      catalogApi.outputs.appId
      fulfillmentProcessor.outputs.appId
    ]
    apimId: apim.outputs.apimId
    sqlId: sql.outputs.sqlServerId
  }
}

// ── Outputs ─────────────────────────────────────────────────────────────
output apimGatewayUrl string = apim.outputs.gatewayUrl
output keyVaultName string = keyVault.outputs.vaultName
output storageAccountName string = storage.outputs.accountName
output serviceBusNamespace string = serviceBus.outputs.namespaceName
output sqlServerFqdn string = sql.outputs.sqlServerFqdn
output appInsightsName string = monitoring.outputs.appInsightsName

/*
  ShopFlow — Azure SQL Bicep Module
  Zone-redundant General Purpose server + database, failover group, VNet firewall rules.
*/
param location string
param environment string
param adminLogin string
@secure() param adminPassword string
param sqlServerName string = 'sql-shopflow-${environment}-${uniqueString(resourceGroup().id)}'

var databaseName = 'ShopFlowDB'
var failoverGroupName = 'fg-shopflow-${environment}'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
  }
  identity: { type: 'SystemAssigned' }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: environment == 'prod' ? 'GP_Gen5_2' : 'GP_Gen5_1'
    tier: 'GeneralPurpose'
  }
  properties: {
    zoneRedundant: true
    autoPauseDelay: environment == 'dev' ? 60 : -1
  }
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource logicalSqlServerDr 'Microsoft.Sql/servers@2022-05-01-preview' = if (environment == 'prod') {
  name: '${sqlServerName}-dr'
  location: 'southindia' // Co-located DR region; parameterize per env
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
  }
}

resource failoverGroup 'Microsoft.Sql/servers/failoverGroups@2022-05-01-preview' = if (environment == 'prod') {
  parent: sqlServer
  name: failoverGroupName
  properties: {
    readWriteEndpoint: { failoverPolicy: 'Automatic', failoverWithDataLossGracePeriodMinutes: 15 }
    databases: [ sqlDb.id ]
    partnerServers: [ { id: logicalSqlServerDr.id } ]
  }
}

output sqlServerId string = sqlServer.id
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = sqlDb.name

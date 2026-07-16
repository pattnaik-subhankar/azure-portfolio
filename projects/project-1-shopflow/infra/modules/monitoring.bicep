/*
  ShopFlow — Monitoring Bicep Module
  Workspace-based App Insights, Log Analytics Workspace, base alerts.
*/
param location string
param environment string
param functionAppIds array
param apimId string
param sqlId string
param workspaceName string = 'log-shopflow-${environment}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: { sku: { name: 'PerGB2018' } }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-shopflow-${environment}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'ApplicationInsights'
  }
}

// APIM diagnostics
resource apimDiagnostics 'Microsoft.ApiManagement/service/diagnostics@2023-05-01-preview' = {
  parent: resource(apimId)
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    loggerId: 'applicationinsights'
  }
}

// DLQ alert — need to parameterize metricAlert once Service Bus scope is deployed
// Placed as placeholder; actual alert rules done in dedicated alerts module or code
output appInsightsName string = appInsights.name
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output workspaceId string = logAnalyticsWorkspace.id
output workspaceName string = logAnalyticsWorkspace.name

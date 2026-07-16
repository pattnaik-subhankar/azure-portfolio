/*
  ShopFlow — Front Door Bicep Module
  Standard tier, WAF policy, origin = APIM, caching for catalog GETs.
*/
param location string
param environment string
param apimFqdn string
param profileName string = 'afd-shopflow-${environment}'

resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: 'waf-shopflow-${environment}'
  location: 'Global'
  sku: { name: 'Standard_AzureFrontDoor' }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: environment == 'prod' ? 'Prevention' : 'Detection'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
          ruleSetAction: 'Block'
        }
      ]
    }
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: profileName
  location: 'global'
  sku: { name: 'Standard_AzureFrontDoor' }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  parent: frontDoorProfile
  name: 'endpoint-shopflow-${environment}'
  properties: { enabledState: 'Enabled' }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  parent: frontDoorProfile
  name: 'og-apim-${environment}'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/status-0123456789abcdef'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 60
    }
  }
}

output frontDoorHostName string = endpoint.properties.hostName
output frontDoorId string = frontDoorProfile.id

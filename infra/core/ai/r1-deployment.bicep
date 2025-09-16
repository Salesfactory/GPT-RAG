param name string
param location string = resourceGroup().location
param gpt41Capacity int = 500
param o4MiniCapacity int = 150
var aiServiceName = '${name}-aiservice'

resource deepseekR1AIService 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: aiServiceName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: aiServiceName
    publicNetworkAccess: 'Enabled'
  }
}

resource gpt41Deployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: deepseekR1AIService
  name: 'gpt-4.1'

  sku: {
    name: 'DataZoneStandard'
    capacity: gpt41Capacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4.1'
      version: '2025-04-14'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: gpt41Capacity
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

resource o4MiniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: deepseekR1AIService
  name: 'o4-mini'
  dependsOn: [
    gpt41Deployment
  ]
  sku: {
    name: 'DataZoneStandard'
    capacity: o4MiniCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'o4-mini'
      version: '2025-04-16'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: o4MiniCapacity
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}
output r1Endpoint string = 'https://${deepseekR1AIService.name}.cognitiveservices.azure.com/models'
output r1Key string = deepseekR1AIService.listKeys().key1

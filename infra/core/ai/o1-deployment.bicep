param name string
param location string = 'eastus2'
param publicNetworkAccess string = 'Enabled'
param kind string = 'OpenAI'
param gpt41Capacity int
param o4miniCapacity int
param sku object = {
  name: 'S0'
}
param tags object = {
  environment: 'production'
  service: 'openai'
}

resource o1Account 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    customSubDomainName: name
    publicNetworkAccess: publicNetworkAccess
  }
  sku: sku
}

resource gpt41Deployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: o1Account
  name: 'gpt-4.1'
  sku: {
    name: 'DataZoneStandard'
    capacity: gpt41Capacity
  }
  properties: {
    model: {
      format: kind
      name: 'gpt-4.1'
      version: '2025-04-14'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: gpt41Capacity
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

resource o4miniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: o1Account
  name: 'o4-mini'
  dependsOn: [
    gpt41Deployment
  ]
  sku: {
    name: 'DataZoneStandard'
    capacity: o4miniCapacity
  }
  properties: {
    model: {
      format: kind
      name: 'o4-mini'
      version: '2025-04-16'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: o4miniCapacity
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}
output o1Endpoint string = o1Account.properties.endpoint
output o1Key string = o1Account.listKeys().key1

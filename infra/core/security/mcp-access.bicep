param principalId string
param functionAppName string

resource functionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: functionAppName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(functionApp.id, principalId, 'AzureAIProjectManager')
  scope: functionApp
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'eadc314b-1a2d-4efa-be10-5d325db5065e'
    )
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

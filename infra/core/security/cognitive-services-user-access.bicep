param cognitiveServiceAccountName string
param principalId string

// Cognitive Services User role assignment for the specific AI services resource
// This grants permission to use the Cognitive Services (including Document Intelligence)
resource cognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(cognitiveServiceAccount.id, principalId, 'cognitive-services-user')
  scope: cognitiveServiceAccount
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'a97b65f3-24c7-4388-baec-2e87135dc908'
    ) // Cognitive Services User
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource cognitiveServiceAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: cognitiveServiceAccountName
}

output roleAssignmentId string = cognitiveServicesUserRoleAssignment.id
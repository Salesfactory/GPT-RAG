param principalId string

// Contributor role assignment at resource group level
// This grants permission to create and manage resources within the resource group
resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, principalId, 'contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b24988ac-6180-42a0-ab88-20f7382dd24c'
    ) // Contributor
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output roleAssignmentId string = contributorRoleAssignment.id
@description('Name of the Cosmos DB account')
param cosmosAccountName string

@description('Name of the Log Analytics workspace')
param logAnalyticsWorkspaceName string

@description('Resource group of the Log Analytics workspace')
param logAnalyticsWorkspaceResourceGroup string = resourceGroup().name

@description('Enable PartitionKeyStatistics logs for tracking storage usage per partition')
param enablePartitionKeyStats bool = true

@description('Enable PartitionKeyRUConsumption logs for tracking RU consumption per partition (critical for multi-tenant billing)')
param enablePartitionKeyRUConsumption bool = true

@description('Enable DataPlaneRequests logs for detailed request tracking')
param enableDataPlaneRequests bool = false

@description('Enable QueryRuntimeStatistics logs for query performance analysis')
param enableQueryRuntimeStats bool = false

@description('Name for the diagnostic settings resource')
param diagnosticSettingsName string = 'cosmos-partition-monitoring'

// Reference existing Cosmos DB account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosAccountName
}

// Reference existing Log Analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroup)
}

// Diagnostic settings for Cosmos DB
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: cosmosAccount
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'PartitionKeyStatistics'
        enabled: enablePartitionKeyStats
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'PartitionKeyRUConsumption'
        enabled: enablePartitionKeyRUConsumption
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'DataPlaneRequests'
        enabled: enableDataPlaneRequests
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: enableQueryRuntimeStats
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'Requests'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

@description('Name of the diagnostic settings resource')
output diagnosticSettingsName string = diagnosticSettings.name

@description('Resource ID of the Log Analytics workspace')
output workspaceId string = logAnalyticsWorkspace.id

@description('Resource ID of the Cosmos DB account')
output cosmosAccountId string = cosmosAccount.id

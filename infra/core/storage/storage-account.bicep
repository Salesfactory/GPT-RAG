param name string
param location string = resourceGroup().location
param tags object = {
  'azd-env-name': 'develop-clew'
}

@allowed(['Hot', 'Cool', 'Premium'])
param accessTier string = 'Hot'
param allowBlobPublicAccess bool = false
param allowCrossTenantReplication bool = true
param allowSharedKeyAccess bool = true
param defaultToOAuthAuthentication bool = false
param deleteRetentionPolicy object = {
  allowPermanentDelete: false
  days: 3
  enabled: true
}
@allowed(['AzureDnsZone', 'Standard'])
param dnsEndpointType string = 'Standard'
param kind string = 'StorageV2'
param minimumTlsVersion string = 'TLS1_2'
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'
param sku object = { name: 'Standard_LRS' }
param secretName string = 'storageConnectionString'
param keyVaultName string

param containers array = [
  {
    name: 'emails'
    publicAccess: 'None'
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
  }
  {
    name: 'emails-archived'
    publicAccess: 'None'
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
  }
  {
    name: 'financial-reports'
    publicAccess: 'None'
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
  }
  {
    name: 'financial-reports-archived'
    publicAccess: 'None'
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
  }
]

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: sku
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    dnsEndpointType: dnsEndpointType
    minimumTlsVersion: minimumTlsVersion
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    publicNetworkAccess: publicNetworkAccess
  }

  resource blobServices 'blobServices' = if (!empty(containers)) {
    name: 'default'
    properties: {
      deleteRetentionPolicy: deleteRetentionPolicy
      cors: {
        corsRules: [
          {
            allowedHeaders: [ '*' ]
            allowedMethods: [ 'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS', 'POST', 'PATCH' ]
            allowedOrigins: [
              'https://mlworkspace.azure.ai'
              'https://ml.azure.com'
              'https://*.ml.azure.com'
              'https://ai.azure.com'
              'https://*.ai.azure.com'
            ]
            exposedHeaders: [ '*' ]
            maxAgeInSeconds: 1800
          }
          {
            allowedHeaders: [ '*' ]
            allowedMethods: [ 'GET', 'OPTIONS', 'POST', 'PUT' ]
            allowedOrigins: [ '*' ]
            exposedHeaders: [ '*' ]
            maxAgeInSeconds: 200
          }
        ]
      }
    }
    resource container 'containers' = [
      for container in containers: {
        name: container.name
        properties: {
          publicAccess: contains(container, 'publicAccess') ? container.publicAccess : 'None'
          defaultEncryptionScope: contains(container, 'defaultEncryptionScope') ? container.defaultEncryptionScope : '$account-encryption-key'
          denyEncryptionScopeOverride: contains(container, 'denyEncryptionScopeOverride') ? container.denyEncryptionScopeOverride : false
        }
      }
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secretName
  tags: tags
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
      exp: 0
      nbf: 0
    }
    contentType: 'string'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
  }
}

output name string = storage.name
output id string = storage.id
output primaryEndpoints object = storage.properties.primaryEndpoints


// to run this module: az deployment group what-if --resource-group < rg-name> --template-file infra/core/storage/storage-account.bicep --parameters name=<storage-name> keyVaultName=<key-vault-name>

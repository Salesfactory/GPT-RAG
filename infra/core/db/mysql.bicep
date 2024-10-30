param name string
param location string
param tags object
param administratorLogin string
@secure()
param administratorLoginPassword string
param databaseName string
param keyVaultName string
param secretName string
param sku object

@description('Azure database for MySQL pricing tier')
@allowed([
  'Basic'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'Basic'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource mysqlServer 'Microsoft.DBforMySQL/servers@2020-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku.name
    tier: skuTier
    capacity: sku.capacity
    size: string(sku.size)
    family: sku.family
  }
  properties: {
    createMode: 'Default'
    version: '8.0'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: sku.size
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    minimalTlsVersion: 'TLS1_2'
    sslEnforcement: 'Enabled'
  }
}

resource database 'Microsoft.DBforMySQL/servers/databases@2020-01-01' = {
  parent: mysqlServer
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}

resource mysqlPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: secretName
  properties: {
    value: administratorLoginPassword
  }
}

resource firewallRule 'Microsoft.DBforMySQL/servers/firewallRules@2017-12-01' = {
  parent: mysqlServer
  name: 'AllowAllAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

output id string = mysqlServer.id
output name string = mysqlServer.name
output databaseName string = database.name
output serverFullyQualifiedDomainName string = '${mysqlServer.name}.mysql.database.azure.com'

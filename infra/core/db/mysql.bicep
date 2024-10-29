param name string
param location string
param tags object
param administratorLogin string
@secure()
param administratorLoginPassword string
param databaseName string
param keyVaultName string
param publicNetworkAccess string = 'Enabled'
param secretName string
param sku object

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource mysqlServer 'Microsoft.DBforMySQL/flexibleServers@2021-12-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: sku
  properties: {
    version: '8.0.21'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    highAvailability: {
      mode: 'Disabled'
      standbyAvailabilityZone: '2'
    }
    storage: {
      storageSizeGB: 20
      iops: 360
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
  }
}

resource database 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-01' = {
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

resource firewallRule 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-06-01' = {
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

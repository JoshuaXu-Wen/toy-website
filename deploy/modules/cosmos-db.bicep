@description('The Azure region into which the resources should be deployed.')
param location string

@description('The type of environment. This must be nonprod or prod.')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

@description('The name of the Cosmos DB account. This name must be globally unique.')
param cosmosDBAccountName string

var cosmosDBDatabaseName = 'ProductCatalog'
var cosmosDBDatabaseThroughput  = (environmentType == 'prod') ? 1000 : 400
var cosmosDBContainerName = 'Products'
var cosmosDBContainerPartitionKey = '/productid'

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' = {
  name: cosmosDBAccountName
  location: location
  // kind: 'GlobalDocumentDB'
  properties: {
    // consistencyPolicy: {
    //   defaultConsistencyLevel: 'Eventual'
    //   maxStalenessPrefix: 1
    //   maxIntervalInSeconds: 5
    // }
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    databaseAccountOfferType: 'Standard'
    // enableAutomaticFailover: true
    // capabilities: [
    //   {
    //     name: 'EnableTable'
    //   }
    // ]
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
  parent: cosmosDbAccount
  name: cosmosDBDatabaseName
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }

  resource container 'containers@2021-06-15' = {
    name: cosmosDBContainerName
    properties: {
      resource: {
        id: cosmosDBContainerName
        partitionKey: {
          paths: [
            cosmosDBContainerPartitionKey
          ]
          kind: 'Hash'
        }
      }
      options: {}
    }
  }
}

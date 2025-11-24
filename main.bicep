// ------------------
//    PARAMETERS
// ------------------

@description('Location for all resources')
param location string = resourceGroup().location

// ------------------
//    VARIABLES
// ------------------

var resourceSuffix = uniqueString(subscription().id, resourceGroup().id)
var containerRegistryName = 'acr${resourceSuffix}'
var containerAppEnvName = 'aca-env-${resourceSuffix}'
var logAnalyticsWorkspaceName = 'law-${resourceSuffix}'
var avmMcpServerAppName = 'aca-avm-${resourceSuffix}'
var pricingMcpServerAppName = 'aca-pricing-${resourceSuffix}'
var managedIdentityName = 'aca-mi-${resourceSuffix}'

// ------------------
//    RESOURCES
// ------------------

// 1. Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// 2. Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    encryption: {
      status: 'disabled'
    }
    metadataSearch: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 7
        status: 'disabled'
      }
    }
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
}

// 3. Managed Identity for Container Apps
resource containerAppUAI 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: managedIdentityName
  location: location
}

// 4. Role Assignment for ACR Pull
var acrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
resource containerAppUAIRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, containerAppUAI.id, acrPullRole)
  properties: {
    roleDefinitionId: acrPullRole
    principalId: containerAppUAI.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// 5. Container App Environment
resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: containerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// 6. AVM MCP Server Container App
resource avmMcpServerContainerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: avmMcpServerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerAppUAI.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        allowInsecure: true
        transport: 'http'
      }
      registries: [
        {
          identity: containerAppUAI.id
          server: containerRegistry.properties.loginServer
        }
      ]
    }
    template: {
      containers: [
        {
          name: avmMcpServerAppName
          image: 'docker.io/jfxs/hello-world:latest'
          env: [
            {
              name: 'MCP_HOST'
              value: '0.0.0.0'
            }
            {
              name: 'MCP_PORT'
              value: '8080'
            }
            {
              name: 'MCP_DEBUG'
              value: 'false'
            }
          ]
          resources: {
            cpu: json('.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

// 7. Azure Pricing MCP Server Container App
resource pricingMcpServerContainerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: pricingMcpServerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerAppUAI.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        allowInsecure: true
        transport: 'http'
      }
      registries: [
        {
          identity: containerAppUAI.id
          server: containerRegistry.properties.loginServer
        }
      ]
    }
    template: {
      containers: [
        {
          name: pricingMcpServerAppName
          image: 'docker.io/jfxs/hello-world:latest'
          env: [
            {
              name: 'MCP_HOST'
              value: '0.0.0.0'
            }
            {
              name: 'MCP_PORT'
              value: '8080'
            }
            {
              name: 'MCP_DEBUG'
              value: 'false'
            }
          ]
          resources: {
            cpu: json('.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

// ------------------
//    OUTPUTS
// ------------------

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.properties.customerId
output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer

output avmMcpServerContainerAppName string = avmMcpServerContainerApp.name
output avmMcpServerFQDN string = avmMcpServerContainerApp.properties.configuration.ingress.fqdn
output avmMcpServerURL string = 'https://${avmMcpServerContainerApp.properties.configuration.ingress.fqdn}'

output pricingMcpServerContainerAppName string = pricingMcpServerContainerApp.name
output pricingMcpServerFQDN string = pricingMcpServerContainerApp.properties.configuration.ingress.fqdn
output pricingMcpServerURL string = 'https://${pricingMcpServerContainerApp.properties.configuration.ingress.fqdn}'

output managedIdentityPrincipalId string = containerAppUAI.properties.principalId
output managedIdentityClientId string = containerAppUAI.properties.clientId

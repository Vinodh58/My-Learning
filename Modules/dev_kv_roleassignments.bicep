
@maxLength(24)
param keyVaultName string

@allowed([
  'dev'
  'stg'
  'uat'
  'prod'
])
param deploymentStage string

@description('SET_Developers Azure AD Group')
param devPrincipalId string = '1f16345f-a423-4a08-906e-34c6d8e87ddb' 


@description('This is the built-in Key Vault Administrator role. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource keyVaultAdministrator 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: subscription()
}

@description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '4633458b-17de-408a-b874-0445c86b69e6'
  scope: subscription()
}

@description('SET Azure Admins - Azure AD Group')
param azureAdminPrincipalId string = 'eb486c7b-9fab-4940-babe-9c9b605680d1' 

resource keyVault_res 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource devTeamRoleAssignment_res 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (deploymentStage == 'dev' ) {
  name: guid(resourceGroup().id, devPrincipalId, keyVault_res.id, keyVaultAdministrator.id)
  scope: keyVault_res
  properties: {
    principalId: devPrincipalId
    roleDefinitionId: keyVaultAdministrator.id
    principalType: 'Group'
  }
}

// ToDo: For stg, uncomment the below and comment for other env. This is to avoid template error during deployment.

resource stgAzureAdminsRoleAssignment_res 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (deploymentStage == 'stg' ) {
  name: guid(resourceGroup().id, azureAdminPrincipalId, keyVault_res.id, keyVaultAdministrator.id)
  scope: keyVault_res
  properties: {
    principalId: azureAdminPrincipalId
    roleDefinitionId: keyVaultAdministrator.id
    principalType: 'Group'
  }
}


resource stgDevTeamRoleAssignment_res 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (deploymentStage == 'stg' ) {
  name: guid(resourceGroup().id, devPrincipalId, keyVault_res.id, keyVaultSecretsUser.id)
  scope: keyVault_res
  properties: {
    principalId: devPrincipalId
    roleDefinitionId: keyVaultSecretsUser.id
    principalType: 'Group'
  }
} 

// uncomment when needed
// ToDo: Fix the multiple templates error and then uncomment this. 
/* 
resource uatAzureAdminsRoleAssignment_res 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (deploymentStage == 'uat' ) {
  name: guid(resourceGroup().id, azureAdminPrincipalId, keyVault_res.id, keyVaultAdministrator.id)
  scope: keyVault_res
  properties: {
    principalId: azureAdminPrincipalId
    roleDefinitionId: keyVaultAdministrator.id
    principalType: 'Group'
  }
}

resource uatDevTeamRoleAssignment_res 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (deploymentStage == 'uat' ) {
  name: guid(resourceGroup().id, devPrincipalId, keyVault_res.id, keyVaultSecretsUser.id)
  scope: keyVault_res
  properties: {
    principalId: devPrincipalId
    roleDefinitionId: keyVaultSecretsUser.id
    principalType: 'Group'
  }
}
 */

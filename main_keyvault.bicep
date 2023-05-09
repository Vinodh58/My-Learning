param location string = resourceGroup().location
//param already_created bool = true
param deploymentStage string = 'dev'

resource keyVault_res 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: 'kv-set-dev-poc-c'
  location: location 
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    // Check createMode options. [ default | recover ]
    createMode: 'default'
    // Check provisioningState options.
    // provisioningState: ?
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true 
  }
}

module devsKvRoleAssignment_mod './Modules/dev_kv_roleassignments.bicep' = {
  name: 'devsKvRoleAssignment_Deploy'
  params: {
    deploymentStage: deploymentStage
    keyVaultName: keyVault_res.name
  }
}

resource keyVaultSecret_res 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault_res
  name: 'spectrum'
  properties: {
    value:'miketestin'
    attributes:{
      enabled:true
    }
  }
}

output keyVaultObjOutput object = keyVault_res
output keyVaultNameOutput string = keyVault_res.name

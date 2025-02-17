param location string = resourceGroup().location
param vnetName string = 'MyVNet'
param subnetNames array = ['Subnet1', 'Subnet2']
param nsgName string = 'MyNSG'
param allowedSSHIP string = '104.28.220.247/32' // Change this to your IP

param vmName string = 'Task11LinuxVM'
param adminUsername string = 'azureuser'
param sshPublicKey string
param storageAccountName string = 'task11bicepsa'
param vmSize string = 'Standard_B2s'

module network './network.bicep' = {
  name: 'networkDeployment'
  params: {
    vnetName: vnetName
    subnetNames: subnetNames
    nsgName: nsgName
    allowedSSHIP: allowedSSHIP
    location: location
  }
}

module vm './vm.bicep' = {
  name: 'vmModule'
  params: {
    vmName: vmName
    location: location
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    subnetId: network.outputs.subnetIds[0] // ✅ Correct reference
    nsgId: network.outputs.nsgId
    storageAccountName: storageAccountName
    vmSize: vmSize
  }
}

output publicIp string = vm.outputs.publicIp

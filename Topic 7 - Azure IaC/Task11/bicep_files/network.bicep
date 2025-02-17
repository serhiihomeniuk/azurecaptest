// Parameters
param vnetName string
param location string
param subnetNames array
param nsgName string
param allowedSSHIP string

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.50.0.0/20']
    }
    subnets: [ 
      for subnet in subnetNames: {
        name: subnet
        properties: {
          addressPrefix: '10.50.${indexOf(subnetNames, subnet)}.0/24'
        }
      }
    ]
  }
}

// Network Security Group (NSG)
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          priority: 1001
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: allowedSSHIP
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

// Construct subnet IDs manually since we cannot reference vnet.properties.subnets at runtime
output vnetId string = vnet.id
output subnetIds array = [for subnet in subnetNames: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${vnet.name}/subnets/${subnet}']
output nsgId string = nsg.id
output publicIp object = publicIp


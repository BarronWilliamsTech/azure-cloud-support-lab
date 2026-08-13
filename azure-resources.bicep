param location string = resourceGroup().location
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = { name: 'vnet-contoso-health' 
location: location 
properties: { addressSpace: {
addressPrefixes: [ '10.0.0.0/16' ] } 
subnets: [ { name: 'snet-servers-windows' 
properties: { addressPrefix: '10.0.1.0/24' } } 
{ name: 'snet-servers-linux' 
properties: { addressPrefix: '10.0.2.0/24' } } ] }}

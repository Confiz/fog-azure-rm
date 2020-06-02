require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file(File.expand_path('credentials/azure.yml', __dir__))

resource = Fog::Resources::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

network = Fog::Network::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

begin
  resource_group = resource.resource_groups.create(
    name: 'TestRG-GCE',
    location: Config.location
  )

  network.virtual_networks.create(
    name: 'testVnet',
    location: Config.location,
    resource_group: 'TestRG-GCE',
    network_address_list: '10.1.0.0/16,10.2.0.0/16'
  )

  network.subnets.create(
    name: 'GatewaySubnet',
    resource_group: 'TestRG-GCE',
    virtual_network_name: 'testVnet',
    address_prefix: '10.2.0.0/24'
  )

  network.public_ips.create(
    name: 'mypubip',
    resource_group: 'TestRG-GCE',
    location: Config.location,
    public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  network.virtual_network_gateways.create(
    name: 'testnetworkgateway',
    location: Config.location,
    tags: {
      key1: 'value1',
      key2: 'value2'
    },
    ip_configurations: [
      {
        name: 'default',
        private_ipallocation_method: 'Dynamic',
        public_ipaddress_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-GCE/providers/Microsoft.Network/publicIPAddresses/mypubip",
        subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-GCE/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/GatewaySubnet",
        private_ipaddress: nil
      }
    ],
    resource_group: 'TestRG-GCE',
    sku_name: 'Standard',
    sku_tier: 'Standard',
    sku_capacity: 2,
    gateway_type: 'ExpressRoute',
    enable_bgp: false,
    gateway_size: nil,
    vpn_type: 'RouteBased',
    vpn_client_address_pool: nil
  )

  ########################################################################################################################
  ###############          Create Virtual Network Gateway Connection to Express Route Circuit                  ###########
  ########################################################################################################################

  connection = network.virtual_network_gateway_connections.create(
    name: 'testnetworkgateway-to-expressroute',
    location: Config.location,
    resource_group: 'TestRG-GCE',
    virtual_network_gateway1: {
      name: 'testnetworkgateway',
      resource_group: 'TestRG-GCE'
    },
    # Please provide Provisioned Express Route Circuit resource id below
    peer: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroup/TestRG-GCE/providers/Microsoft.Network/expressRouteCircuits/[circuit_name]",
    connection_type: 'ExpressRoute'
  )
  puts "Created virtual network gateway connection to express route circuit: #{connection.name}"

  ########################################################################################################################
  ######################                                       CleanUp                             #######################
  ########################################################################################################################

  gateway_connection = network.virtual_network_gateway_connections.get('TestRG-GCE', 'testnetworkgateway-to-expressroute')
  puts "Get virtual network gateway connection to express route circuit: #{gateway_connection.name}"
  puts "Deleted virtual network gateway connection to express route circuit: #{gateway_connection.destroy}"

  network_gateway = network.virtual_network_gateways.get('TestRG-GCE', 'testnetworkgateway')
  network_gateway.destroy

  pubip = network.public_ips.get('TestRG-GCE', 'mypubip')
  pubip.destroy

  vnet = network.virtual_networks.get('TestRG-GCE', 'testVnet')
  vnet.destroy

  resource_group = resource.resource_groups.get('TestRG-GCE')
  resource_group.destroy
rescue
  puts 'Integration Test for virtual network gateway connection to express route circuit is failing'
  resource_group.destroy unless resource_group.nil?
end

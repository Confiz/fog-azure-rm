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
    name: 'TestRG-VNG',
    location: Config.location
  )

  network.virtual_networks.create(
    name: 'testVnet',
    location: Config.location,
    resource_group: 'TestRG-VNG',
    network_address_list: '10.1.0.0/16,10.2.0.0/16'
  )

  network.subnets.create(
    name: 'GatewaySubnet',
    resource_group: 'TestRG-VNG',
    virtual_network_name: 'testVnet',
    address_prefix: '10.2.0.0/24'
  )

  network.public_ips.create(
    name: 'mypubip',
    resource_group: 'TestRG-VNG',
    location: Config.location,
    public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  ########################################################################################################################
  ######################                    Check Virtual Network Gateway Exists                    ######################
  ########################################################################################################################

  flag = network.virtual_network_gateways.check_vnet_gateway_exists('TestRG-VNG', 'testnetworkgateway')
  puts "Virtual Network Gateway doesn't exist." unless flag

  ########################################################################################################################
  ######################                           Create Virtual Network Gateway                   ######################
  ########################################################################################################################

  virtual_network_gateway = network.virtual_network_gateways.create(
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
        public_ipaddress_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VNG/providers/Microsoft.Network/publicIPAddresses/mypubip",
        subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VNG/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/GatewaySubnet",
        private_ipaddress: nil
      }
    ],
    resource_group: 'TestRG-VNG',
    sku_name: 'Standard',
    sku_tier: 'Standard',
    sku_capacity: 2,
    gateway_type: 'ExpressRoute',
    enable_bgp: false,
    gateway_size: nil,
    vpn_type: 'RouteBased',
    vpn_client_address_pool: nil
  )
  puts "Created virtual network gateway: #{virtual_network_gateway.name}"

  ########################################################################################################################
  ######################                      List Virtual Network Gateways                         ######################
  ########################################################################################################################

  network_gateways = network.virtual_network_gateways(resource_group: 'TestRG-VNG')
  puts 'List virtual network gateways:'
  network_gateways.each do |gateway|
    puts gateway.name
  end

  ########################################################################################################################
  ######################                  Get Virtual Network Gateway and CleanUp                   ######################
  ########################################################################################################################

  network_gateway = network.virtual_network_gateways.get('TestRG-VNG', 'testnetworkgateway')
  puts "Get virtual network gateway: #{network_gateway.name}"

  puts "Deleted virtual network gateway: #{network_gateway.destroy}"

  rg = resource.resource_groups.get('TestRG-VNG')
  rg.destroy
rescue
  puts 'Integration Test for virtual network gateway is failing'
  resource_group.destroy unless resource_group.nil?
end

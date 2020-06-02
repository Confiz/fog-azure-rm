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
    name: 'TestRG-LNG',
    location: Config.location
  )

  ########################################################################################################################
  ######################                   Check Local Network Gateway Exists?                      ######################
  ########################################################################################################################

  flag = network.local_network_gateways.check_local_net_gateway_exists('TestRG-LNG', 'testlocalnetworkgateway')
  puts "Local Network Gateway doesn't exist." unless flag

  ########################################################################################################################
  ######################                           Create Local Network Gateway                   ######################
  ########################################################################################################################

  local_network_gateway = network.local_network_gateways.create(
    name: 'testlocalnetworkgateway',
    location: Config.location,
    tags: {
      key1: 'value1',
      key2: 'value2'
    },
    resource_group: 'TestRG-LNG',
    gateway_ip_address: '192.168.1.1',
    local_network_address_space_prefixes: [],
    asn: 100,
    bgp_peering_address: '192.168.1.2',
    peer_weight: 3
  )
  puts "Created local network gateway: #{local_network_gateway.name}"

  ########################################################################################################################
  ######################                      List Local Network Gateways                           ######################
  ########################################################################################################################

  local_network_gateways = network.local_network_gateways(resource_group: 'TestRG-LNG')
  puts 'List local network gateways:'
  local_network_gateways.each do |gateway|
    puts gateway.name
  end

  ########################################################################################################################
  ######################                        Get Local Network Gateway                           ######################
  ########################################################################################################################

  local_network_gateway = network.local_network_gateways.get('TestRG-LNG', 'testlocalnetworkgateway')
  puts "Get local network gateway: #{local_network_gateway.name}"

  ########################################################################################################################
  ######################                              CleanUp                                       ######################
  ########################################################################################################################

  puts "Deleted local network gateway: #{local_network_gateway.destroy}"

  resource_group = resource.resource_groups.get('TestRG-LNG')
  resource_group.destroy
  puts 'Integration Test for local network gateway ran successfully'
rescue
  puts 'Integration Test for local network gateway is failing'
  resource_group.destroy unless resource_group.nil?
end

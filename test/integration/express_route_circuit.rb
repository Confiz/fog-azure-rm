require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file(File.expand_path('credentials/azure.yml', __dir__))

resources = Fog::Resources::AzureRM.new(
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
  resource_group = resources.resource_groups.create(
    name: 'TestRG-ER',
    location: Config.location
  )
  Fog::Logger.debug 'Resource Group created!'

  ########################################################################################################################
  ######################                  Check Express Route Circuit Exists?                       ######################
  ########################################################################################################################

  flag = network.express_route_circuits.check_express_route_circuit_exists('TestRG-ER', 'testERCircuit')
  puts "Express Route Circuit doesn't exist." unless flag

  ########################################################################################################################
  ################                               Create Express Route Circuit                            #################
  ########################################################################################################################

  express_route_circuit = network.express_route_circuits.create(
    name: 'testERCircuit',
    location: Config.location,
    tags: {
      key1: 'value1',
      key2: 'value2'
    },
    resource_group: 'TestRG-ER',
    sku_name: 'Standard_MeteredData',
    sku_tier: 'Standard',
    sku_family: 'MeteredData',
    service_provider_name: 'Telenor',
    peering_location: 'London',
    bandwidth_in_mbps: 100,
    peerings: [
      {
        name: 'AzurePublicPeering',
        peering_type: 'AzurePublicPeering',
        peer_asn: 100,
        primary_peer_address_prefix: '192.168.1.0/30',
        secondary_peer_address_prefix: '192.168.2.0/30',
        vlan_id: 200
      }
    ]
  )
  puts "Created express route circuit: #{express_route_circuit.name}"

  ########################################################################################################################
  ######################                           List Express Route Circuit                         ####################
  ########################################################################################################################

  circuits = network.express_route_circuits(resource_group: 'TestRG-ER')
  puts 'List express route circuits:'
  circuits.each do |circuit|
    puts circuit.name
  end

  ########################################################################################################################
  ######################             Check Express Route Circuit Authorization Exists?              ######################
  ########################################################################################################################

  flag = network.express_route_circuit_authorizations.check_express_route_cir_auth_exists('TestRG-ER', 'testERCircuit', 'Test-Auth')
  puts "Express Route Circuit Authorization doesn't exist." unless flag

  ########################################################################################################################
  ######################                Create Express Route Circuit Authorizations                   ####################
  ########################################################################################################################
  express_route_circuit_authorization = network.express_route_circuit_authorizations.create(
    resource_group: 'TestRG-ER',
    circuit_name: 'testERCircuit',
    authorization_use_status: 'Available',
    authorization_name: 'Test-Auth',
    name: 'Unique-Auth-Name'
  )
  puts "Created express route circuit authorization: #{express_route_circuit_authorization.name}"

  ########################################################################################################################
  ######################                Get a Express Route Circuit Authorization                     ####################
  ########################################################################################################################
  authorization = network.express_route_circuit_authorizations.get('TestRG-ER', 'testERCircuit', 'Test-Auth')
  puts "Get express route circuit authorization: #{authorization.name}"

  ########################################################################################################################
  ######################                List Express Route Circuit Authorizations                     ####################
  ########################################################################################################################
  authorizations = network.express_route_circuit_authorizations(resource_group: 'TestRG-ER', circuit_name: 'testERCircuit')
  puts 'List express route circuit authorizations:'
  authorizations.each do |auth|
    puts auth.name
  end

  ########################################################################################################################
  ######################                Destroy Express Route Circuit Authorization                   ####################
  ########################################################################################################################
  authorization = network.express_route_circuit_authorizations.get('TestRG-ER', 'testERCircuit', 'Test-Auth')
  puts "Deleted express route circuit authorization: #{authorization.destroy}"

  ########################################################################################################################
  ######################                   Destroy Express Route Circuit                            ######################
  ########################################################################################################################
  circuit = network.express_route_circuits.get('TestRG-ER', 'testERCircuit')
  puts "Deleted express route circuit: #{circuit.destroy}"

  ########################################################################################################################
  ######################                         CleanUp                                            ######################
  ########################################################################################################################
  resource_group = resources.resource_groups.get('TestRG-ER')
  resource_group.destroy
  puts 'Integration Test for express route circuit ran successfully'
rescue
  puts 'Integration Test for express route circuit is failing'
  resource_group.destroy unless resource_group.nil?
end

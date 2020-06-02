require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file(File.expand_path('credentials/azure.yml', __dir__))

rs = Fog::Resources::AzureRM.new(
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
  resource_group = rs.resource_groups.create(
    name: 'TestRG-VN',
    location: Config.location
  )

  ########################################################################################################################
  ######################                          Check Virtual Network Exists                      ######################
  ########################################################################################################################

  flag = network.virtual_networks.check_virtual_network_exists('TestRG-VN', 'testVnet')
  puts "Virtual Network doesn't exist." unless flag

  ########################################################################################################################
  ######################            Create Virtual Network with complete parameters list            ######################
  ########################################################################################################################

  virtual_network = network.virtual_networks.create(
    name:             'testVnet',
    location:         Config.location,
    resource_group:   resource_group.name,
    subnets:          [{
      name: 'mysubnet',
      address_prefix: '10.1.0.0/24'
    }],
    dns_servers:       %w(10.1.0.0 10.2.0.0),
    address_prefixes:  %w(10.1.0.0/16 10.2.0.0/16),
    tags: { key: 'value' }
  )
  puts "Created virtual network: #{virtual_network.name}"

  ########################################################################################################################
  ######################          List Virtual Network in a subscription                 #################################
  ########################################################################################################################

  virtual_networks = network.virtual_networks
  puts 'List virtual_networks in subscription:'
  virtual_networks.each do |a_virtual_network|
    puts a_virtual_network.name
  end

  ########################################################################################################################
  ######################                      List Virtual Network                       #################################
  ########################################################################################################################

  virtual_networks = network.virtual_networks(resource_group: resource_group.name)
  puts 'List virtual_networks:'
  virtual_networks.each do |a_virtual_network|
    puts a_virtual_network.name
  end

  ########################################################################################################################
  ######################                      Get Virtual Network                       ##################################
  ########################################################################################################################

  vnet = network.virtual_networks.get('TestRG-VN', 'testvnet')
  puts "Get virtual network: #{vnet.name}"

  ########################################################################################################################
  ######################                Add/Remove DNS Servers to/from Virtual Network           #########################
  ########################################################################################################################

  vnet.add_dns_servers(%w(10.3.0.0 10.4.0.0))
  puts 'Added dns servers to virtual network'

  vnet.remove_dns_servers(%w(10.3.0.0 10.4.0.0))
  puts 'Remove dns servers from virtual network'

  ########################################################################################################################
  ######################                Add/Remove Address Prefixes to/from Virtual Network      #########################
  ########################################################################################################################

  vnet.add_address_prefixes(%w(10.2.0.0/16 10.3.0.0/16))
  puts 'Added address prefixes to virtual network'

  vnet.remove_address_prefixes(['10.2.0.0/16'])
  puts 'Removed address prefixes from virtual network'

  ########################################################################################################################
  ######################                Add/Remove Subnets to/from Virtual Network           #############################
  ########################################################################################################################

  vnet.add_subnets(
    [
      {
        name: 'test-subnet',
        address_prefix: '10.3.0.0/24'
      }
    ]
  )
  puts 'Added subnet to virtual network'

  vnet.remove_subnets(['test-subnet'])
  puts 'Removed subnet from virtual network'

  ########################################################################################################################
  ######################                Update Virtual Network                                  ##########################
  ########################################################################################################################

  vnet.update(
    subnets:
      [
        {
          name: 'fog-subnet',
          address_prefix: '10.3.0.0/16'
        }
      ],
    dns_servers: %w(10.3.0.0 10.4.0.0)
  )
  puts 'Updated virtual network'

  ########################################################################################################################
  ######################                List Free IP Address count in Subnets                   ##########################
  ########################################################################################################################

  puts 'List free ip address count in subnets:'
  vnet.subnets.each do |subnet|
    puts network.subnets.get('TestRG-VN', 'testVnet', subnet.name).get_available_ipaddresses_count(false)
  end

  ########################################################################################################################
  ######################                Destroy Virtual Network                                  #########################
  ########################################################################################################################

  puts "Deleted virtual network: #{vnet.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  resource_group.destroy
rescue
  puts 'Integration Test for virtual network is failing'
  resource_group.destroy unless resource_group.nil?
end

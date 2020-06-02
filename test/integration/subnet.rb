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
    name: 'TestRG-SN',
    location: Config.location
  )

  virtual_network = network.virtual_networks.create(
    name:             'testVnet',
    location:         Config.location,
    resource_group:   'TestRG-SN',
    dns_servers:       %w(10.1.0.0 10.2.0.0),
    address_prefixes:  %w(10.1.0.0/16 10.2.0.0/16)
  )

  network_security_group = network.network_security_groups.create(
    name: 'testGroup',
    resource_group: resource_group.name,
    location: Config.location
  )

  ########################################################################################################################
  ######################                         Check Subnet Exists?                               ######################
  ########################################################################################################################

  flag = network.subnets.check_subnet_exists('TestRG-SN', 'testVnet', 'mysubnet')
  puts "Subnet doesn't exist." unless flag

  ########################################################################################################################
  ######################                                Create Subnet                               ######################
  ########################################################################################################################

  subnet = network.subnets.create(
    name: 'mysubnet',
    resource_group: resource_group.name,
    virtual_network_name: virtual_network.name,
    address_prefix: '10.1.0.0/24'
  )
  puts "Created subnet: #{subnet.name}"

  ########################################################################################################################
  ######################              Attach/Detach Network Security Group                          ######################
  ########################################################################################################################

  subnet.attach_network_security_group(network_security_group.id)
  puts 'Attached network_security_group'
  subnet.detach_network_security_group
  puts 'Detached network_security_group'

  ########################################################################################################################
  ##################### Attach/Detach Route Table(Pending because Route Table is not implemented yet) ###################
  ########################################################################################################################

  ########################################################################################################################
  ######################                             List Subnets                                   ######################
  ########################################################################################################################

  subnets = network.subnets(resource_group: resource_group.name, virtual_network_name: virtual_network.name)
  puts 'List subnets:'
  subnets.each do |a_subnet|
    puts a_subnet.name
  end

  ########################################################################################################################
  ######################                             Get Subnet                          ######################
  ########################################################################################################################

  subnet = network.subnets.get(resource_group.name, virtual_network.name, subnet.name)
  puts "Get subnet: #{subnet.name}"

  ########################################################################################################################
  ######################                        List Free Ip Addresses in Subnet                    ######################
  ########################################################################################################################

  puts "Free ip addresses in subnet: #{subnet.get_available_ipaddresses_count(false)}"

  ########################################################################################################################
  ######################                             Delete Subnet                          ######################
  ########################################################################################################################

  puts "Deleted subnet: #{subnet.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  network_security_group.destroy

  virtual_network.destroy

  resource_group.destroy
rescue
  puts 'Integration Test for subnet is failing'
  resource_group.destroy unless resource_group.nil?
end

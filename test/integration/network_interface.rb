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
    name: 'TestRG-NI',
    location: Config.location
  )

  network.virtual_networks.create(
    name: 'testVnet',
    location: Config.location,
    resource_group: 'TestRG-NI',
    network_address_list: '10.1.0.0/16,10.2.0.0/16'
  )

  network.subnets.create(
    name: 'mysubnet',
    resource_group: 'TestRG-NI',
    virtual_network_name: 'testVnet',
    address_prefix: '10.2.0.0/24'
  )

  network.subnets.create(
    name: 'mysubnet1',
    resource_group: 'TestRG-NI',
    virtual_network_name: 'testVnet',
    address_prefix: '10.2.1.0/24'
  )

  network.public_ips.create(
    name: 'mypubip',
    resource_group: 'TestRG-NI',
    location: Config.location,
    public_ip_allocation_method: 'Dynamic'
  )

  network.public_ips.create(
    name: 'mypubip1',
    resource_group: 'TestRG-NI',
    location: Config.location,
    public_ip_allocation_method: 'Dynamic'
  )

  network.public_ips.create(
    name: 'mypubip2',
    resource_group: 'TestRG-NI',
    location: LOCATION,
    public_ip_allocation_method: 'Dynamic'
  )

  nsg = network.network_security_groups.create(
    name: 'test_nsg',
    resource_group: 'TestRG-NI',
    location: Config.location,
    security_rules:
      [
        {
          name: 'testRule',
          protocol: 'tcp',
          source_port_range: '22',
          destination_port_range: '22',
          source_address_prefix: '0.0.0.0/0',
          destination_address_prefix: '0.0.0.0/0',
          access: 'Allow',
          priority: '100',
          direction: 'Inbound'
        }
      ]
  )

  ########################################################################################################################
  ######################                      Check Network Interface Exists?                       ######################
  ########################################################################################################################

  flag = network.network_interfaces.check_network_interface_exists('TestRG-NI', 'NetInt')
  puts "Network Interface doesn't exist." unless flag

  ########################################################################################################################
  ######################                           Create Network Interface                         ######################
  ########################################################################################################################

  network_interface = network.network_interfaces.create(
    name: 'NetInt',
    resource_group: 'TestRG-NI',
    location: Config.location,
    network_security_group_id: nsg.id,
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-NI/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet",
    public_ip_address_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-NI/providers/Microsoft.Network/publicIPAddresses/mypubip",
    ip_configuration_name: 'testIpConfiguration',
    private_ip_allocation_method: 'Dynamic',
    tags: { key: 'value' },
    enable_accelerated_networking: true
  )
  puts "Created network interface: #{network_interface.name}"

  ########################################################################################################################
  ######################                       Create Network Interface Async                       ######################
  ########################################################################################################################

  async_response = network.network_interfaces.create_async(
    name: 'NetInt_Async',
    resource_group: 'TestRG-NI',
    location: LOCATION,
    network_security_group_id: nsg.id,
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-NI/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet",
    public_ip_address_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-NI/providers/Microsoft.Network/publicIPAddresses/mypubip2",
    ip_configuration_name: 'testIpConfiguration',
    private_ip_allocation_method: 'Dynamic',
    tags: { key: 'value' },
    enable_accelerated_networking: true
  )

  loop do
    if async_response.pending?
      sleep(2)
      print '.'
    end

    if async_response.fulfilled?
      puts "\nCreated/Updated NIC asynchronously! [#{async_response.value.name}]"
      break
    end

    if async_response.rejected?
      puts "\nERROR: Async NIC creation failed!\n#{async_response.reason.inspect}"
      break
    end
  end

  ########################################################################################################################
  ######################                       Get Network Interface and Update Resources           ######################
  ########################################################################################################################

  nic = network.network_interfaces.get('TestRG-NI', 'NetInt')
  puts "Get network interface: #{nic.name}"

  subnet_id = "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-NI/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet1"
  nic.attach_subnet(subnet_id)
  puts 'Updated subnet id of network_interface'

  public_ip = "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-NI/providers/Microsoft.Network/publicIPAddresses/mypubip1"
  nic.attach_public_ip(public_ip)
  puts 'Updated public ip of network_interface'

  nsg_ip = "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-NI/providers/Microsoft.Network/networkSecurityGroups/test_nsg"
  nic.attach_network_security_group(nsg_ip)
  puts 'Updated network security group ip of network_interface'

  nic.detach_public_ip
  puts 'Detached public ip from network_interface'

  nic.detach_network_security_group
  puts 'Detached network security group from network_interface'

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  puts "Deleted network interface: #{nic.destroy}"

  nic_async = network.network_interfaces.get('TestRG-NI', 'NetInt_Async')
  puts "Deleted network interface #{nic_async.name}: #{nic_async.destroy}"

  pubip = network.public_ips.get('TestRG-NI', 'mypubip')
  pubip.destroy

  vnet = network.virtual_networks.get('TestRG-NI', 'testVnet')
  vnet.destroy

  rg = rs.resource_groups.get('TestRG-NI')
  rg.destroy
  puts 'Integration Test for network interface ran successfully'
rescue
  puts 'Integration Test for network interface is failing'
  resource_group.destroy unless resource_group.nil?
end

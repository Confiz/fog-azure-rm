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

compute = Fog::Compute::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

storage = Fog::Storage::AzureRM.new(
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
    name: 'TestRG-VME',
    location: Config.location
  )

  storage_account_name = "sa#{current_time}"
  storage.storage_accounts.create(
    name: storage_account_name,
    location: Config.location,
    resource_group: 'TestRG-VME',
    account_type: 'Standard',
    replication: 'LRS'
  )

  network.virtual_networks.create(
    name:             'testVnet',
    location:         Config.location,
    resource_group:   'TestRG-VME',
    network_address_list:  '10.1.0.0/16,10.2.0.0/16'
  )

  network.subnets.create(
    name: 'mysubnet',
    resource_group: 'TestRG-VME',
    virtual_network_name: 'testVnet',
    address_prefix: '10.2.0.0/24'
  )

  network.network_interfaces.create(
    name: 'NetInt',
    resource_group: 'TestRG-VME',
    location: Config.location,
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VME/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet",
    ip_configuration_name: 'testIpConfiguration',
    private_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  compute.servers.create(
    name: 'TestVM',
    location: Config.location,
    resource_group: 'TestRG-VME',
    vm_size: 'Basic_A0',
    storage_account_name: storage_account_name,
    username: 'testuser',
    password: 'Confiz=123',
    disable_password_authentication: false,
    network_interface_card_ids: ["/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VME/providers/Microsoft.Network/networkInterfaces/NetInt"],
    publisher: 'MicrosoftWindowsServer',
    offer: 'WindowsServer',
    sku: '2008-R2-SP1',
    version: 'latest',
    platform: 'Windows'
  )

  ########################################################################################################################
  ######################                  Check Virtual Machine Extension Exists?                   ######################
  ########################################################################################################################

  flag = compute.virtual_machine_extensions.check_vm_extension_exists('TestRG-VME', 'TestVM', 'IaasAntimalware')
  puts "Virtual machine extension doesn't exist." unless flag

  ########################################################################################################################
  ######################                         Attach Extension To Server                         ######################
  ########################################################################################################################

  vm_extension = compute.virtual_machine_extensions.create(
    resource_group: 'TestRG-VME',
    location: Config.location,
    vm_name: 'TestVM',
    name: 'IaaSAntimalware',
    publisher: 'Microsoft.Azure.Security',
    type: 'IaaSAntimalware',
    type_handler_version: '1.3',
    auto_upgrade_minor_version: true,
    settings: { 'AntimalwareEnabled' => 'true', 'RealtimeProtectionEnabled' => 'false', 'ScheduledScanSettings' => { 'isEnabled' => 'false', 'day' => '7', 'time' => '120', 'scanType' => 'Quick' }, 'Exclusions' => { 'Extensions' => '', 'Paths' => '', 'Processes' => '' } },
    protected_settings: {}
  )
  puts "Attached virtual machine extension: #{vm_extension.name}"

  ########################################################################################################################
  ######################                         Get Extension From Server                          ######################
  ########################################################################################################################

  vm_extension = compute.virtual_machine_extensions.get('TestRG-VME', 'TestVM', 'IaasAntimalware')
  puts "Get vm extension: #{vm_extension.name}"

  ########################################################################################################################
  ######################                              Update Extension                              ######################
  ########################################################################################################################

  vm_extension.update(auto_upgrade_minor_version: false)
  puts 'Updated vm extension'

  ########################################################################################################################
  ######################                              Delete Extension                              ######################
  ########################################################################################################################

  puts "Deleted vm extension: #{vm_extension.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  virtual_machine = compute.servers.get('TestRG-VME', 'TestVM')
  virtual_machine.destroy

  nic = network.network_interfaces.get('TestRG-VME', 'NetInt')
  nic.destroy

  vnet = network.virtual_networks.get('TestRG-VME', 'testVnet')
  vnet.destroy

  storage = storage.storage_accounts.get('TestRG-VME', storage_account_name)
  storage.destroy

  resource_group = rs.resource_groups.get('TestRG-VME')
  resource_group.destroy
  puts 'Integration Test for virtual machine extension ran successfully'
rescue
  puts 'Integration Test for vm extension is failing'
  resource_group.destroy unless resource_group.nil?
end

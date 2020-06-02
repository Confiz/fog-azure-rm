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

RG_NAME = 'TestRG-CustomVM'.freeze

begin
  resource_group = rs.resource_groups.create(
    name: RG_NAME,
    location: Config.location
  )

  storage_account_name = "sa#{current_time}"

  storage.storage_accounts.create(
    name: storage_account_name,
    location: Config.location,
    resource_group: RG_NAME,
    account_type: 'Standard',
    replication: 'LRS'
  )

  network.virtual_networks.create(
    name: 'testVnet',
    location: Config.location,
    resource_group: RG_NAME,
    network_address_list: '10.1.0.0/16,10.2.0.0/16'
  )

  network.subnets.create(
    name: 'mysubnet',
    resource_group: RG_NAME,
    virtual_network_name: 'testVnet',
    address_prefix: '10.2.0.0/24'
  )

  network.network_interfaces.create(
    name: 'NetInt',
    resource_group: RG_NAME,
    location: Config.location,
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{RG_NAME}/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet",
    ip_configuration_name: 'testIpConfiguration',
    private_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  network.network_interfaces.create(
    name: 'NetInt2',
    resource_group: RG_NAME,
    location: Config.location,
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{RG_NAME}/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet",
    ip_configuration_name: 'testIpConfiguration',
    private_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  network.network_interfaces.create(
    name: 'NetInt3',
    resource_group: RG_NAME,
    location: Config.location,
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{RG_NAME}/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet",
    ip_configuration_name: 'testIpConfiguration',
    private_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  ########################################################################################################################
  ######################                                Create Server                               ######################
  ########################################################################################################################

  vhd_path = 'https://myblob.blob.core.windows.net/vhds/my_vhd.vhd'.freeze

  custom_image_virtual_machine = compute.servers.create(
    name: 'TestVM',
    location: Config.location,
    resource_group: RG_NAME,
    storage_account_name: storage_account_name,
    vm_size: 'Basic_A0',
    username: 'testuser',
    password: 'Confiz=123',
    disable_password_authentication: false,
    network_interface_card_ids: ["/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{RG_NAME}/providers/Microsoft.Network/networkInterfaces/NetInt"],
    platform: 'linux',
    vhd_path: vhd_path
  )

  puts "Created custom image un-managed virtual machine: #{custom_image_virtual_machine.name}"

  ########################################################################################################################
  #################                                Create Managed Server                               ###################
  ########################################################################################################################

  custom_image_virtual_machine_managed = compute.servers.create(
    name: 'TestVM-Managed',
    location: Config.location,
    resource_group: RG_NAME,
    storage_account_name: storage_account_name,
    vm_size: 'Basic_A0',
    username: 'testuser',
    password: 'Confiz=123',
    disable_password_authentication: false,
    network_interface_card_ids: ["/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{RG_NAME}/providers/Microsoft.Network/networkInterfaces/NetInt2"],
    platform: 'linux',
    vhd_path: vhd_path,
    managed_disk_storage_type: Azure::ARM::Compute::Models::StorageAccountTypes::StandardLRS
  )

  puts "Created custom image managed virtual machine: #{custom_image_virtual_machine_managed.name}"

  ########################################################################################################################
  ##############                                Create Managed Server Async                               ################
  ########################################################################################################################

  print 'Creating Virtual Machine asynchronously...'

  async_response = compute.servers.create_async(
    name: 'TestVM-ManagedAsync',
    location: Config.location,
    resource_group: RG_NAME,
    storage_account_name: storage_account_name,
    vm_size: 'Basic_A0',
    username: 'testuser',
    password: 'Confiz=123',
    disable_password_authentication: false,
    network_interface_card_ids: ["/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{RG_NAME}/providers/Microsoft.Network/networkInterfaces/NetInt3"],
    platform: 'linux',
    vhd_path: vhd_path,
    managed_disk_storage_type: Azure::ARM::Compute::Models::StorageAccountTypes::StandardLRS
  )

  loop do
    if async_response.pending?
      sleep(2)
      print '.'
    end

    if async_response.fulfilled?
      puts "\nCreated custom image managed virtual machine: #{async_response.value.name}"
      break
    end

    if async_response.rejected?
      puts "\nERROR: Async VM creation failed!\n#{async_response.reason.inspect}"
      break
    end
  end

  ########################################################################################################################
  ######################                            Get and Delete Server                           ######################
  ########################################################################################################################

  custom_image_virtual_machine = compute.servers.get(RG_NAME, 'TestVM')
  puts "Get custom image un-managed virtual machine: #{custom_image_virtual_machine.name}"
  puts "Deleted custom image un-managed virtual machine: #{custom_image_virtual_machine.destroy}"

  custom_image_virtual_machine_managed = compute.servers.get(RG_NAME, 'TestVM-Managed')
  puts "Get custom image managed virtual machine: #{custom_image_virtual_machine_managed.name}"
  puts "Deleted custom image managed virtual machine: #{custom_image_virtual_machine_managed.destroy}"

  custom_image_virtual_machine_managed_async = compute.servers.get(RG_NAME, 'TestVM-ManagedAsync')
  puts "Get custom image managed virtual machine async: #{custom_image_virtual_machine_managed_async.name}"
  puts "Deleted custom image managed virtual machine async: #{custom_image_virtual_machine_managed_async.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  puts 'Cleaning up...'

  nic = network.network_interfaces.get(RG_NAME, 'NetInt')
  nic.destroy

  nic = network.network_interfaces.get(RG_NAME, 'NetInt2')
  nic.destroy

  nic = network.network_interfaces.get(RG_NAME, 'NetInt3')
  nic.destroy

  vnet = network.virtual_networks.get(RG_NAME, 'testVnet')
  vnet.destroy

  storage = storage.storage_accounts.get(RG_NAME, storage_account_name)
  storage.destroy

  resource_group = rs.resource_groups.get(RG_NAME)
  resource_group.destroy

  puts 'Integration Test for virtual machine ran successfully!'
rescue
  puts 'Integration Test for custom image virtual machine is failing'
  resource_group.destroy unless resource_group.nil?
end

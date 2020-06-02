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
    name: 'TestRG-VM',
    location: Config.location
  )

  storage_account_name = "sa#{current_time}"

  storage_account = storage.storage_accounts.create(
    name: storage_account_name,
    location: Config.location,
    resource_group: 'TestRG-VM',
    account_type: 'Standard',
    replication: 'LRS'
  )

  network.virtual_networks.create(
    name: 'testVnet',
    location: Config.location,
    resource_group: 'TestRG-VM',
    network_address_list: '10.1.0.0/16,10.2.0.0/16'
  )

  network.subnets.create(
    name: 'mysubnet',
    resource_group: 'TestRG-VM',
    virtual_network_name: 'testVnet',
    address_prefix: '10.2.0.0/24'
  )

  network.network_interfaces.create(
    name: 'NetInt',
    resource_group: 'TestRG-VM',
    location: Config.location,
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VM/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet",
    ip_configuration_name: 'testIpConfiguration',
    private_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  network.network_interfaces.create(
    name: 'NetInt2',
    resource_group: 'TestRG-VM',
    location: Config.location,
    subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VM/providers/Microsoft.Network/virtualNetworks/testVnet/subnets/mysubnet",
    ip_configuration_name: 'testIpConfiguration',
    private_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  ########################################################################################################################
  ######################                            Check for Virtual Machine                       ######################
  ########################################################################################################################

  flag = compute.servers.check_vm_exists('TestRG-VM', 'TestVM')
  puts 'Virtual Machine does NOT exist!' unless flag

  ########################################################################################################################
  ######################                                  Create Server                             ######################
  ########################################################################################################################

  puts 'Creating un-managed Virtual Machine...'

  tags = { key1: 'value1', key2: 'value2' }

  virtual_machine = compute.servers.create(
    name: 'TestVM',
    location: Config.location,
    resource_group: 'TestRG-VM',
    tags: tags,
    vm_size: 'Basic_A0',
    storage_account_name: storage_account_name,
    username: 'testuser',
    password: 'Confiz=123',
    disable_password_authentication: false,
    network_interface_card_ids: ["/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VM/providers/Microsoft.Network/networkInterfaces/NetInt"],
    publisher: 'Canonical',
    offer: 'UbuntuServer',
    sku: '14.04.2-LTS',
    version: 'latest',
    platform: 'linux',
    custom_data: 'echo customData',
    os_disk_caching: Fog::ARM::Compute::Models::CachingTypes::None
  )
  puts "Created un-managed virtual machine: #{virtual_machine.name}"

  ########################################################################################################################
  ######################                            Create Managed Server                           ######################
  ########################################################################################################################

  puts 'Creating managed Virtual Machine...'

  managed_vm = compute.servers.create(
    name: 'TestVM-Managed',
    location: Config.location,
    resource_group: 'TestRG-VM',
    vm_size: 'Standard_B2s',
    storage_account_name: nil,
    username: 'testuser',
    password: 'Confiz=123',
    disable_password_authentication: false,
    network_interface_card_ids: ["/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VM/providers/Microsoft.Network/networkInterfaces/NetInt2"],
    publisher: 'Canonical',
    offer: 'UbuntuServer',
    sku: '14.04.2-LTS',
    version: 'latest',
    platform: 'linux',
    custom_data: 'echo customData',
    os_disk_caching: Fog::ARM::Compute::Models::CachingTypes::None,
    managed_disk_storage_type: Azure::ARM::Compute::Models::StorageAccountTypes::StandardLRS
  )
  puts "Created managed virtual machine: #{managed_vm.name}"

  ########################################################################################################################
  ######################                                Create Server Async                           ####################
  ########################################################################################################################

  print 'Creating Virtual Machine asynchronously...'

  async_response = compute.servers.create_async(
    name: 'TestVM',
    location: Config.location,
    resource_group: 'TestRG-VM',
    tags: tags,
    vm_size: 'Basic_A0',
    storage_account_name: storage_account_name,
    username: 'testuser',
    password: 'Confiz=123',
    disable_password_authentication: false,
    network_interface_card_ids: ["/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-VM/providers/Microsoft.Network/networkInterfaces/NetInt"],
    publisher: 'Canonical',
    offer: 'UbuntuServer',
    sku: '14.04.2-LTS',
    version: 'latest',
    platform: 'linux',
    custom_data: 'echo customData',
    os_disk_caching: Fog::ARM::Compute::Models::CachingTypes::None
  )

  loop do
    if async_response.pending?
      sleep(2)
      print '.'
    end

    if async_response.fulfilled?
      puts "\nCreated VM asynchronously! [#{async_response.value.name}]"
      break
    end

    if async_response.rejected?
      puts "\nERROR: Async VM creation failed!\n#{async_response.reason.inspect}"
      break
    end
  end

  ########################################################################################################################
  ######################                          Attach Data Disk to VM                            ######################
  ########################################################################################################################

  virtual_machine = compute.servers.get('TestRG-VM', 'TestVM')
  virtual_machine.attach_data_disk('datadisk1', 10, storage_account_name)
  puts 'Attached Data Disk to VM!'

  ########################################################################################################################
  ######################                          Detach Data Disk from VM                          ######################
  ########################################################################################################################

  virtual_machine = compute.servers.get('TestRG-VM', 'TestVM')
  virtual_machine.detach_data_disk('datadisk1')
  puts 'Detached Data Disk from VM!'

  ########################################################################################################################
  ######################                                Delete Data Disk                            ######################
  ########################################################################################################################

  access_key = storage_account.get_access_keys[0].value
  Fog::Logger.debug access_key.inspect
  storage_data = Fog::Storage::AzureRM.new(
    azure_storage_account_name: storage_account.name,
    azure_storage_access_key: access_key
  )
  puts "Deleted data disk: #{storage_data.delete_disk('datadisk1')}"

  ########################################################################################################################
  ######################                       Create a Managed Data Disk                           ######################
  ########################################################################################################################

  managed_disk = compute.managed_disks.create(
    name: 'ManagedDataDisk',
    location: Config.location,
    resource_group_name: 'TestRG-VM',
    account_type: 'Standard_LRS',
    disk_size_gb: 100,
    creation_data: {
      create_option: 'Empty'
    }
  )
  puts "Created Managed Disk: #{managed_disk.name}"

  managed_disk_ro = compute.managed_disks.create(
    name: 'ManagedDataDiskRO',
    location: LOCATION,
    resource_group_name: 'TestRG-VM',
    account_type: 'Standard_LRS',
    disk_size_gb: 100,
    creation_data: {
      create_option: 'Empty'
    }
  )
  puts "Created Managed Disk: #{managed_disk_ro.name}"

  managed_disk_rw = compute.managed_disks.create(
    name: 'ManagedDataDiskRW',
    location: LOCATION,
    resource_group_name: 'TestRG-VM',
    account_type: 'Standard_LRS',
    disk_size_gb: 100,
    creation_data: {
      create_option: 'Empty'
    }
  )
  puts "Created Managed Disk: #{managed_disk_rw.name}"

  ########################################################################################################################
  ######################                          Attach Managed Data Disk to VM                    ######################
  ########################################################################################################################

  managed_vm.attach_managed_disk('ManagedDataDisk', 'TestRG-VM')
  puts 'Attached Managed Data Disk to VM!'

  managed_vm.attach_managed_disk('ManagedDataDiskRO', 'TestRG-VM', false, 'ReadOnly')
  puts 'Attached Managed Data Disk with Disk Caching ReadOnly to VM!'

  managed_vm.attach_managed_disk('ManagedDataDiskRW', 'TestRG-VM', false, 'ReadWrite')
  puts 'Attached Managed Data Disk with Disk Caching ReadWrite to VM!'

  ########################################################################################################################
  ######################                          Detach Data Disk from VM                          ######################
  ########################################################################################################################

  managed_vm.detach_managed_disk('ManagedDataDisk')
  puts 'Detached Managed Data Disk from VM!'

  managed_vm.detach_managed_disk('ManagedDataDiskRO')
  puts 'Detached Managed Data Disk with Disk Caching ReadOnly from VM!'

  managed_vm.detach_managed_disk('ManagedDataDiskRW')
  puts 'Detached Managed Data Disk with Disk Caching ReadWrite from VM!'

  ########################################################################################################################
  ######################                         Delete Managed Data Disk                           ######################
  ########################################################################################################################

  managed_disk.destroy
  puts 'Deleted managed data disk!'

  managed_disk_ro.destroy
  puts 'Deleted managed data disk with Disk Caching ReadOnly!'

  managed_disk_rw.destroy
  puts 'Deleted managed data disk with Disk Caching ReadWrite!'

  ########################################################################################################################
  ######################                      List VM in a resource group                           ######################
  ########################################################################################################################

  virtual_machines = compute.servers(resource_group: 'TestRG-VM')
  puts 'List virtual machines in a resource group:'
  virtual_machines.each do |vm|
    puts "- #{vm.name}"
  end

  #######################################################################################################################
  #####################                                 Get VM                                     ######################
  #######################################################################################################################

  virtual_machine = compute.servers.get('TestRG-VM', 'TestVM')
  puts "Get virtual machine: #{virtual_machine.name}"

  ########################################################################################################################
  ######################                      List available sizes in VM                            ######################
  ########################################################################################################################

  puts 'List of available sizes for Virtual Machine:'
  available_sizes_for_vm = virtual_machine.list_available_sizes
  available_sizes_for_vm.each do |available_size|
    puts "- #{available_size.name}"
  end

  ########################################################################################################################
  ######################                                Restart VM                                  ######################
  ########################################################################################################################

  virtual_machine.restart
  puts 'Virtual machine restarted!'

  ########################################################################################################################
  ######################                               Redeploy VM                                  ######################
  ########################################################################################################################

  virtual_machine.redeploy
  puts 'Virtual machine redeployed!'

  ########################################################################################################################
  ######################                              Deallocate VM                                 ######################
  ########################################################################################################################

  virtual_machine.deallocate
  puts 'Virtual machine de-allocated!'

  ########################################################################################################################
  ######################                                 Start VM                                   ######################
  ########################################################################################################################

  virtual_machine.start
  puts 'Virtual machines started!'

  ########################################################################################################################
  ######################                              Power Off VM                                 ######################
  ########################################################################################################################

  virtual_machine.power_off
  puts 'Virtual machine powered off!'

  ########################################################################################################################
  ######################                                 Delete VM                                  ######################
  ########################################################################################################################

  puts "Deleted virtual machine: #{virtual_machine.destroy}"
  puts "Deleted virtual machine: #{managed_vm.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  puts 'Cleaning up...'

  nic = network.network_interfaces.get('TestRG-VM', 'NetInt')
  nic.destroy

  nic = network.network_interfaces.get('TestRG-VM', 'NetInt2')
  nic.destroy

  vnet = network.virtual_networks.get('TestRG-VM', 'testVnet')
  vnet.destroy

  storage = storage.storage_accounts.get('TestRG-VM', storage_account_name)
  storage.destroy

  resource_group = rs.resource_groups.get('TestRG-VM')
  resource_group.destroy

  puts 'Integration Test for virtual machine ran successfully!'
rescue
  puts 'Integration Test for virtual machine is failing!'
  resource_group.destroy unless resource_group.nil?
end

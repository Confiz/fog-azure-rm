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

storage = Fog::Storage::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id'],
  environment: azure_credentials['environment']
)

########################################################################################################################
######################                               Resource names                                #####################
########################################################################################################################

time = current_time
resource_group_name = "Blob-RG-#{time}"
storage_account_name = "sa#{time}"
container_name = 'vhds'
test_container_name = 'disks'

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

begin
  resource_group = rs.resource_groups.create(
    name: resource_group_name,
    location: Config.location
  )

  storage_account = storage.storage_accounts.create(
    name: storage_account_name,
    location: Config.location,
    resource_group: resource_group_name
  )

  storage_data = Fog::Storage.new(
    provider: 'AzureRM',
    azure_storage_account_name: storage_account.name,
    azure_storage_access_key: storage_account.get_access_keys[0].value,
    environment: azure_credentials['environment']
  )
  storage_data.directories.create(
    key: container_name,
    public: false
  )
  storage_data.directories.create(
    key: test_container_name,
    public: false
  )

  ########################################################################################################################
  ######################                               Create Disk                                  ######################
  ########################################################################################################################

  storage_data.create_disk('datadisk1', 10)
  puts 'Created a disk in default container vhds'

  storage_data.create_disk('datadisk2', 10, container_name: test_container_name)
  puts 'Created a disk in non-default container'

  ########################################################################################################################
  ######################                                Delete Data Disk                            ######################
  ########################################################################################################################

  storage_data.delete_disk('datadisk1')
  puts 'Deleted a disk in default container vhds'

  storage_data.delete_disk('datadisk2', container_name: test_container_name)
  puts 'Deleted a disk in non-default container'
rescue => ex
  puts "Integration Test for data disk is failing: #{ex.inspect}\n#{ex.backtrace.join("\n")}"
ensure
  resource_group.destroy unless resource_group.nil?
end

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
resource_group_name = "TestRG-SA-#{time}"
storage_account_name = "teststorage#{time}"
lrs_storage_account = "lrs#{time}"
grs_storage_account = "grs#{time}"
premium_storage_acc = "premsa#{time}"

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

begin
  resource_group = rs.resource_groups.create(
    name: resource_group_name,
    location: Config.location
  )

  ########################################################################################################################
  ######################                    Check Storage Account name Availability                 ######################
  ########################################################################################################################

  storage_account_avail = storage.storage_accounts.check_name_availability(storage_account_name)
  puts storage_account_avail ? 'Storage Account name available' : 'Storage Account name unavailable'

  ########################################################################################################################
  ######################                         Check Subnet Exists?                               ######################
  ########################################################################################################################

  flag = storage.storage_accounts.check_storage_account_exists(resource_group_name, lrs_storage_account)
  puts "Storage Account doesn't exist." unless flag

  ########################################################################################################################
  ###############  Create A Standard Storage Account of Replication: LRS (Locally-redundant storage)       ###############
  ########################################################################################################################

  tags = { key1: 'value1', key2: 'value2' }

  storage_account = storage.storage_accounts.create(
    name: lrs_storage_account,
    location: Config.location,
    resource_group: resource_group_name,
    tags: tags
  )
  puts "Created storage account for standard lrs replication: #{storage_account.name}"

  ########################################################################################################################
  ###############      Create A Standard Storage Account of Replication: GRS (Geo-redundant storage)     #################
  ########################################################################################################################

  storage_account = storage.storage_accounts.create(
    name: grs_storage_account,
    location: Config.location,
    resource_group: resource_group_name,
    sku_name: Fog::ARM::Storage::Models::SkuTier::Standard,
    replication: 'GRS',
    encryption: true,
    tags: tags
  )
  puts "Created storage account for standard grs replication: #{storage_account.name}"

  ########################################################################################################################
  ###########   Create A Premium(SSD) Storage Account of its only Replication: LRS (Locally-redundant storage)  ##########
  ########################################################################################################################

  storage_account = storage.storage_accounts.create(
    name: premium_storage_acc,
    location: Config.location,
    resource_group: resource_group_name,
    sku_name: Fog::ARM::Storage::Models::SkuTier::Premium,
    replication: 'LRS',
    tags: tags
  )
  puts "Created storage account for premium lrs replication: #{storage_account.name}"

  ########################################################################################################################
  ######################                         Get and Update Storage Account                     ######################
  ########################################################################################################################

  premium_storage_account = storage.storage_accounts.get(resource_group_name, premium_storage_acc)
  puts "Get storage account: #{premium_storage_account.name}"
  premium_storage_account.update(encryption: true)
  puts 'Updated encryption of storage account'

  ########################################################################################################################
  ######################                         Get and Delete Storage Account                     ######################
  ########################################################################################################################

  standard_storage_account = storage.storage_accounts.get(resource_group_name, lrs_storage_account)
  puts "Deleted storage account for standard lrs replication: #{standard_storage_account.destroy}"
  standard_storage_account = storage.storage_accounts.get(resource_group_name, grs_storage_account)
  puts "Deleted storage account for standard grs replication: #{standard_storage_account.destroy}"
  premium_storage_account = storage.storage_accounts.get(resource_group_name, premium_storage_acc)
  puts "Deleted storage account for premium lrs replication: #{premium_storage_account.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  resource_group = rs.resource_groups.get(resource_group_name)
  resource_group.destroy

  puts 'Integration test for storage account ran successfully!'
rescue
  puts 'Integration Test for storage account is failing'
  resource_group.destroy unless resource_group.nil?
end

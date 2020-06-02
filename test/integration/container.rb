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
container_name = "con#{time}"
test_container_name = "tcon#{time}"

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

begin
  resource_group = rs.resource_groups.create(
    name: resource_group_name,
    location: Config.location
  )

  storage_account_name = "sa#{current_time}"

  storage_account = storage.storage_accounts.create(
    name: storage_account_name,
    location: Config.location,
    resource_group: resource_group_name
  )

  keys = storage_account.get_access_keys
  access_key = keys.first.value

  storage_data = Fog::Storage::AzureRM.new(
    azure_storage_account_name: storage_account.name,
    azure_storage_access_key: access_key,
    environment: azure_credentials['environment']
  )

  ########################################################################################################################
  ######################                             Check Container Exists                         ######################
  ########################################################################################################################

  flag = storage_data.directories.check_container_exists(container_name)
  puts "Container doesn't exist." unless flag

  ########################################################################################################################
  ######################                                Create Container                            ######################
  ########################################################################################################################

  container = storage_data.directories.create(
    key: container_name
  )
  puts "Created container: #{container.key}"

  storage_data.directories.create(
    key: test_container_name,
    public: true
  )
  puts "Created second container: #{container.key}"

  ########################################################################################################################
  ######################                      List containers                                       ######################
  ########################################################################################################################

  containers = storage_data.directories.all
  puts 'List containers:'
  containers.each do |a_container|
    puts a_container.key
  end

  ########################################################################################################################
  ######################                      Get container acl                                     ######################
  ########################################################################################################################

  container = storage_data.directories.get(container_name, max_results: 1)
  puts "Get container: #{container.key}"
  puts "Get container access control list: #{container.acl}"

  ########################################################################################################################
  ######################                          Update Container                                  ######################
  ########################################################################################################################

  container.acl = 'container'
  container.metadata = { 'owner' => 'azure' }
  container.save(is_create: false)
  puts 'Updated container'

  ########################################################################################################################
  ######################                      Get container acl                                     ######################
  ########################################################################################################################

  puts "Get updated container access control list: #{container.acl}"

  ########################################################################################################################
  ######################                      Get container metadata                                ######################
  ########################################################################################################################

  puts "Get container metadata: #{container.metadata}"

  ########################################################################################################################
  ######################                      Get container public https url                        ######################
  ########################################################################################################################

  puts "Get container public url: #{container.public_url}"

  ########################################################################################################################
  ######################                      Get container public http url                         ######################
  ########################################################################################################################

  puts "Get container public url having scheme http: #{container.public_url(scheme: 'http')}"

  ########################################################################################################################
  ######################                            Lease Container                                 ######################
  ########################################################################################################################

  lease_id_container = storage_data.acquire_container_lease(container_name)
  Fog::Logger.debug lease_id_container
  puts 'Leased Container'

  ########################################################################################################################
  ######################                            Release Leased Container                        ######################
  ########################################################################################################################

  storage_data.release_container_lease(container_name, lease_id_container)
  puts 'Release Leased Container'

  ########################################################################################################################
  ######################                                Deleted Container                           ######################
  ########################################################################################################################

  puts "Deleted container: #{container.destroy}"
rescue => ex
  puts "Integration Test for container is failing: #{ex.inspect}\n#{ex.backtrace.join("\n")}"
ensure
  resource_group.destroy unless resource_group.nil?
end

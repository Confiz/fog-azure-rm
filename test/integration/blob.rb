require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file('credentials/azure.yml')

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
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

resource_group = rs.resource_groups.create(
  name: 'TestRG-BLOB',
  location: LOCATION
)

storage_account_name = "fog#{get_time}storageac"

storage_account = storage.storage_accounts.create(
  name: storage_account_name,
  location: LOCATION,
  resource_group: 'TestRG-BLOB'
)

access_key = storage_account.get_access_keys[0].value
Fog::Logger.debug access_key.inspect
storage_data = Fog::Storage.new(
  provider: 'AzureRM',
  azure_storage_account_name: storage_account.name,
  azure_storage_access_key: access_key
)

container_name = 'fogcontainertestblob'
test_container_name = 'testcontainer'

########################################################################################################################
######################                                Create Container                            ######################
########################################################################################################################

storage_data.directories.create(
  key: container_name,
  public: true
)

storage_data.directories.create(
  key: test_container_name,
  public: false
)

########################################################################################################################
######################                      Get container                                         ######################
########################################################################################################################

container = storage_data.directories.get(container_name)
test_container = storage_data.directories.get(test_container_name)

########################################################################################################################
######################                          Create a small block blob                         ######################
########################################################################################################################

small_blob_name = 'small_test_file.dat'
content = Array.new(1024 * 1024) { [*'0'..'9', *'a'..'z'].sample }.join

options = {
  key: small_blob_name,
  body: content
}
container.files.create(options)

########################################################################################################################
######################                          Create a large block blob                         ######################
########################################################################################################################

large_blob_name = 'large_test_file.dat'
begin
  large_blob_file_name = '/tmp/large_test_file.dat'
  File.open(large_blob_file_name, 'w') do |large_file|
    33.times do
      large_file.puts(content)
    end
  end

  File.open(large_blob_file_name) do |file|
    options = {
      key: large_blob_name,
      body: file
    }
    container.files.create(options)
  end
ensure
  File.delete(large_blob_file_name) if File.exist?(large_blob_file_name)
end

########################################################################################################################
######################                          Create a small page blob                          ######################
########################################################################################################################

small_page_blob_name = 'small_test_file.vhd'
content = Array.new(1024 * 1024 + 512) { [*'0'..'9', *'a'..'z'].sample }.join

options = {
  key: small_page_blob_name,
  body: content,
  blob_type: 'PageBlob'
}
container.files.create(options)

########################################################################################################################
######################                          Create a large page blob                          ######################
########################################################################################################################

begin
  large_page_blob_file_name = '/tmp/large_test_file.vhd'
  large_page_blob_name = 'large_test_file.vhd'
  File.open(large_page_blob_file_name, 'w') do |large_file|
    content = Array.new(1024 * 1024) { [*'0'..'9', *'a'..'z'].sample }.join
    33.times do
      large_file.puts(content)
    end
    content = Array.new(512) { [*'0'..'9', *'a'..'z'].sample }.join
    large_file.puts(content)
    large_file.truncate(33 * 1024 * 1024 + 512)
  end

  File.open(large_page_blob_file_name) do |file|
    options = {
      key: large_page_blob_name,
      body: file,
      blob_type: 'PageBlob'
    }
    container.files.create(options)
  end
ensure
  File.delete(large_page_blob_file_name) if File.exist?(large_page_blob_file_name)
end

########################################################################################################################
######################                    Blob Exist                                               #####################
########################################################################################################################

Fog::Logger.debug 'Blob exist' if container.files.head(small_blob_name)

########################################################################################################################
######################                    Copy Blob                                             ########################
########################################################################################################################

container.files.head(small_blob_name).copy(test_container_name, small_blob_name)

########################################################################################################################
######################                            Get a public URL                                ######################
########################################################################################################################

blob_uri = container.files.head(large_blob_name).public_url

########################################################################################################################
######################                    Copy Blob from URI                                    ########################
########################################################################################################################

copied_blob = test_container.files.new(key: 'small_blob_name')
Fog::Logger.debug copied_blob.copy_from_uri(blob_uri)

########################################################################################################################
######################                      Update blob                                           ######################
########################################################################################################################

copied_blob.content_encoding = 'utf-8'
copied_blob.metadata = { 'owner' => 'azure' }
copied_blob.save(update_body: false)

temp = test_container.files.head(small_blob_name)
Fog::Logger.debug temp.content_encoding
Fog::Logger.debug temp.metadata

########################################################################################################################
######################                    Compare Blob                                             #####################
########################################################################################################################

Fog::Logger.debug storage_data.compare_container_blobs(container_name, test_container_name)

########################################################################################################################
######################                    Blob Exist                                               #####################
########################################################################################################################

Fog::Logger.debug 'Blob exist' if container.files.head(small_blob_name)

########################################################################################################################
######################                    Blob Count in a Container                                #####################
########################################################################################################################

Fog::Logger.debug container.files.all.length

########################################################################################################################
######################                    List Blobs in a Container                                #####################
########################################################################################################################

container.files.each do |temp_file|
  Fog::Logger.debug temp_file
end

########################################################################################################################
######################                            Downlaod a small blob                           ######################
########################################################################################################################

begin
  downloaded_file_name = '/tmp/downloaded_' + small_blob_name
  blob = container.files.get(small_blob_name)
  File.open(downloaded_file_name, 'wb') do |file|
    file.write(blob.body)
  end
ensure
  File.delete(downloaded_file_name) if File.exist?(downloaded_file_name)
end

########################################################################################################################
######################                            Downlaod a large blob                           ######################
########################################################################################################################

begin
  downloaded_file_name = '/tmp/downloaded_' + large_blob_name
  File.open(downloaded_file_name, 'wb') do |file|
    container.files.get(large_blob_name) do |chunk, remaining_bytes, total_bytes|
      Fog::Logger.debug "remaining_bytes: #{remaining_bytes}, total_bytes: #{total_bytes}"
      file.write(chunk)
    end
  end
ensure
  File.delete(downloaded_file_name) if File.exist?(downloaded_file_name)
end

########################################################################################################################
######################                            Get a https URL with expires                    ######################
########################################################################################################################

test_blob = test_container.files.head(small_blob_name)
Fog::Logger.debug test_blob.public?
Fog::Logger.debug test_blob.url(Time.now + 3600)

########################################################################################################################
######################                            Get a http URL with expires                     ######################
########################################################################################################################

Fog::Logger.debug test_blob.url(Time.now + 3600, scheme: 'http')

########################################################################################################################
######################                            Lease Blob                                      ######################
########################################################################################################################

lease_id_blob = storage_data.acquire_blob_lease(container_name, large_blob_name)
Fog::Logger.debug lease_id_blob

########################################################################################################################
######################                            Release Leased Blob                             ######################
########################################################################################################################

storage_data.release_blob_lease(container_name, large_blob_name, lease_id_blob)

########################################################################################################################
######################                            Delete Blob                                     ######################
########################################################################################################################

blob = container.files.head(large_blob_name)
blob.destroy

########################################################################################################################
######################                            Lease Container                                 ######################
########################################################################################################################

lease_id_container = storage_data.acquire_container_lease(container_name)
Fog::Logger.debug lease_id_container

########################################################################################################################
######################                            Release Leased Container                        ######################
########################################################################################################################

storage_data.release_container_lease(container_name, lease_id_container)

########################################################################################################################
######################                            Delete Container                                ######################
########################################################################################################################

container.destroy

########################################################################################################################
######################                                   CleanUp                                  ######################
########################################################################################################################

storage_account.destroy

resource_group.destroy

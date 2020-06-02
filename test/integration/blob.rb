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

  storage_account = storage.storage_accounts.create(
    name: storage_account_name,
    location: Config.location,
    resource_group: resource_group_name
  )

  access_key = storage_account.get_access_keys[0].value
  Fog::Logger.debug access_key.inspect
  storage_data = Fog::Storage.new(
    provider: 'AzureRM',
    azure_storage_account_name: storage_account.name,
    azure_storage_access_key: access_key,
    environment: azure_credentials['environment']
  )

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
  blob = container.files.create(options)
  puts "Created small block blob: #{blob.key}"

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
      blob = container.files.create(options)
      puts "Created large block blob: #{blob.key}"
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
  blob = container.files.create(options)
  puts "Created small page blob: #{blob.key}"

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
      blob = container.files.create(options)
      puts "Created large page blob: #{blob.key}"
    end
  ensure
    File.delete(large_page_blob_file_name) if File.exist?(large_page_blob_file_name)
  end

  ########################################################################################################################
  ######################                    Copy Blob                                             ########################
  ########################################################################################################################

  puts "Copy blob: #{container.files.head(small_blob_name).copy(test_container_name, small_blob_name)}"

  ########################################################################################################################
  ######################                            Get a public URL                                ######################
  ########################################################################################################################

  blob_uri = container.files.head(large_blob_name).public_url
  puts "Get blob public uri: #{blob_uri}"

  ########################################################################################################################
  ######################                    Copy Blob from URI                                    ########################
  ########################################################################################################################

  copied_blob = test_container.files.new(key: 'small_blob_name')
  puts "Copy blob from uri: #{copied_blob.copy_from_uri(blob_uri)}"

  ########################################################################################################################
  ######################                      Update blob                                           ######################
  ########################################################################################################################

  copied_blob.content_encoding = 'utf-8'
  copied_blob.metadata = { 'owner' => 'azure' }
  copied_blob.save(update_body: false)

  temp = test_container.files.head(small_blob_name)
  puts 'Updated blob'
  Fog::Logger.debug temp.content_encoding
  Fog::Logger.debug temp.metadata

  ########################################################################################################################
  ######################                    Compare Blob                                             #####################
  ########################################################################################################################

  puts "Compare blobs: #{storage_data.compare_container_blobs(container_name, test_container_name)}"

  ########################################################################################################################
  ######################                    Blob Exist                                               #####################
  ########################################################################################################################

  puts 'Blob exist' if container.files.head(small_blob_name)

  ########################################################################################################################
  ######################                    Blob Count in a Container                                #####################
  ########################################################################################################################

  puts "Blob count in a container: #{container.files.all.length}"

  ########################################################################################################################
  ######################                    List Blobs in a Container                                #####################
  ########################################################################################################################

  puts 'List blobs in a container:'
  container.files.each do |temp_file|
    puts temp_file.key
  end

  ########################################################################################################################
  ######################                            Download a small blob                           ######################
  ########################################################################################################################

  begin
    downloaded_file_name = '/tmp/downloaded_' + small_blob_name
    blob = container.files.get(small_blob_name)
    File.open(downloaded_file_name, 'wb') do |file|
      file.write(blob.body)
    end
    puts 'Downloaded small blob'
  ensure
    File.delete(downloaded_file_name) if File.exist?(downloaded_file_name)
  end

  ########################################################################################################################
  ######################                            Download a large blob                           ######################
  ########################################################################################################################

  begin
    downloaded_file_name = '/tmp/downloaded_' + large_blob_name
    File.open(downloaded_file_name, 'wb') do |file|
      container.files.get(large_blob_name) do |chunk, remaining_bytes, total_bytes|
        Fog::Logger.debug "remaining_bytes: #{remaining_bytes}, total_bytes: #{total_bytes}"
        file.write(chunk)
      end
    end
    puts 'Downloaded large blob'
  ensure
    File.delete(downloaded_file_name) if File.exist?(downloaded_file_name)
  end

  ########################################################################################################################
  ######################                            Get a https URL with expires                    ######################
  ########################################################################################################################

  test_blob = test_container.files.head(small_blob_name)
  puts "Get https URL with expires: #{test_blob.public?}, #{test_blob.url(Time.now + 3600)}"
  Fog::Logger.debug test_blob.public?
  Fog::Logger.debug test_blob.url(Time.now + 3600)

  ########################################################################################################################
  ######################                            Get a http URL with expires                     ######################
  ########################################################################################################################

  puts "Get a http URL with expires: #{test_blob.url(Time.now + 3600, scheme: 'http')}"

  ########################################################################################################################
  ######################                            Lease Blob                                      ######################
  ########################################################################################################################

  lease_id_blob = storage_data.acquire_blob_lease(container_name, large_blob_name)
  puts 'Leased blob'

  ########################################################################################################################
  ######################                            Release Leased Blob                             ######################
  ########################################################################################################################

  storage_data.release_blob_lease(container_name, large_blob_name, lease_id_blob)
  puts 'Release Leased Blob'

  ########################################################################################################################
  ######################                            Delete Blob                                     ######################
  ########################################################################################################################

  blob = container.files.head(large_blob_name)
  puts "Deleted blob: #{blob.destroy}"
rescue => ex
  puts "Integration Test for blob is failing: #{ex.inspect}\n#{ex.backtrace.join("\n")}"
ensure
  resource_group.destroy unless resource_group.nil?
end

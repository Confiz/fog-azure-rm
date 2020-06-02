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
  subscription_id: azure_credentials['subscription_id'],
  environment: azure_credentials['environment']
)

compute = Fog::Compute::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id'],
  environment: azure_credentials['environment']
)

########################################################################################################################
######################                               Resource names                                #####################
########################################################################################################################

time                = current_time
resource_group_name = "TestRG-MD-#{time}"
disk_name           = "MD#{time}"

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

begin
  rs.resource_groups.create(
    name: resource_group_name,
    location: Config.location
  )

  ########################################################################################################################
  ######################                            Check for Managed Disk                          ######################
  ########################################################################################################################

  flag = compute.managed_disks.check_managed_disk_exists(resource_group_name, disk_name)
  puts "Managed Disk doesn't exist." unless flag

  ########################################################################################################################
  ######################                             Create Managed Disk                            ######################
  ########################################################################################################################

  tags = { key1: 'value1', key2: 'value2' }

  disk = compute.managed_disks.create(
    name: disk_name,
    location: Config.location,
    resource_group_name: resource_group_name,
    tags: tags,
    account_type: 'Premium_LRS',
    disk_size_gb: 1023,
    creation_data: {
      create_option: 'Empty'
    }
  )
  puts "Created managed disk: #{disk.name}"

  ########################################################################################################################
  ######################                         Grant and revoke access                            ######################
  ########################################################################################################################

  access_sas = compute.managed_disks.grant_access(resource_group_name, disk_name, 'Read', 1000)
  puts "Access SAS: #{access_sas}"

  response = compute.managed_disks.revoke_access(resource_group_name, disk_name)
  puts "Revoke Access response: #{response.inspect}"

  ########################################################################################################################
  ######################                       List Managed Disks                                   ######################
  ########################################################################################################################

  puts 'List managed disks:'
  compute.managed_disks(resource_group: resource_group_name).each do |managed_disk|
    puts managed_disk.name
  end

  ########################################################################################################################
  ######################                    List all Managed Disks in a subscription                ######################
  ########################################################################################################################

  puts 'List managed disks in Subscription:'
  compute.managed_disks.each do |m_disk|
    puts m_disk.name
  end

  ########################################################################################################################
  ######################                       Get and Delete Managed Disk                          ######################
  ########################################################################################################################

  disk = compute.managed_disks.get(resource_group_name, disk_name)
  puts "Get managed disk: #{disk.inspect}"
  puts "Deleted managed disk: #{disk.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  rg = rs.resource_groups.get(resource_group_name)
  rg.destroy

  puts 'Integration Test for managed disk ran successfully!'
rescue
  puts 'Integration Test for managed disk is failing!'
  resource_group.destroy unless resource_group.nil?
end

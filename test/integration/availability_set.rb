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

time = current_time
resource_group_name       = "TestRG-AS-#{time}"
unmanaged_as_name_default = "ASUnmanagedDefault#{time}"
unmanaged_as_name_custom  = "ASUnmanagedCustom#{time}"
managed_as_name_default   = "ASManagedDefault#{time}"
managed_as_name_custom    = "ASManagedCustom#{time}"

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

begin
  puts 'Running integration test for availability set...'

  puts "Create resource group (#{resource_group_name}):"
  resource_group = rs.resource_groups.create(
    name: resource_group_name,
    location: Config.location
  )
  puts "Created resource group! [#{resource_group.name}]"

  ########################################################################################################################
  ######################                            Check for Availability set                      ######################
  ########################################################################################################################

  puts 'Check for existing availability sets:'

  is_exists = compute.availability_sets.check_availability_set_exists(resource_group_name, unmanaged_as_name_default)
  puts "Availability set does NOT exist! [#{unmanaged_as_name_default}] " unless is_exists

  is_exists = compute.availability_sets.check_availability_set_exists(resource_group_name, unmanaged_as_name_custom)
  puts "Availability set does NOT exist! [#{unmanaged_as_name_custom}] " unless is_exists

  is_exists = compute.availability_sets.check_availability_set_exists(resource_group_name, managed_as_name_default)
  puts "Availability set does NOT exist! [#{managed_as_name_default}] " unless is_exists

  is_exists = compute.availability_sets.check_availability_set_exists(resource_group_name, managed_as_name_custom)
  puts "Availability set does NOT exist! [#{managed_as_name_default}] " unless is_exists

  ########################################################################################################################
  ######################                    Create Unmanaged Availability Set (Default)             ######################
  ########################################################################################################################

  tags = { key1: 'value1', key2: 'value2' }

  puts "Create unmanaged default availability set (#{unmanaged_as_name_default}):"
  avail_set = compute.availability_sets.create(
    name: unmanaged_as_name_default,
    location: Config.location,
    resource_group: resource_group_name,
    tags: tags
  )
  name = avail_set.name
  fault_domains = avail_set.platform_fault_domain_count
  update_domains = avail_set.platform_update_domain_count
  puts "Created availability set! [#{name}] => { fd: #{fault_domains}, ud: #{update_domains} }"

  ########################################################################################################################
  ######################                    Create Unmanaged Availability Set (Custom)              ######################
  ########################################################################################################################

  puts "Create unmanaged custom availability set (#{unmanaged_as_name_custom}):"
  avail_set = compute.availability_sets.create(
    name: unmanaged_as_name_custom,
    location: Config.location,
    resource_group: resource_group_name,
    tags: tags,
    platform_fault_domain_count: 3,
    platform_update_domain_count: 10
  )
  name = avail_set.name
  fault_domains = avail_set.platform_fault_domain_count
  update_domains = avail_set.platform_update_domain_count
  puts "Created availability set! [#{name}] => { fd: #{fault_domains}, ud: #{update_domains} }"

  ########################################################################################################################
  ######################                    Create Managed Availability Set (Default)               ######################
  ########################################################################################################################

  puts "Create managed default availability set (#{managed_as_name_default}):"
  avail_set = compute.availability_sets.create(
    name: managed_as_name_default,
    location: Config.location,
    resource_group: resource_group_name,
    tags: tags,
    use_managed_disk: true
  )
  name = avail_set.name
  fault_domains = avail_set.platform_fault_domain_count
  update_domains = avail_set.platform_update_domain_count
  puts "Created availability set! [#{name}] => { fd: #{fault_domains}, ud: #{update_domains} }"

  ########################################################################################################################
  ######################                     Create Managed Availability Set (Custom)               ######################
  ########################################################################################################################

  puts "Create managed custom availability set (#{managed_as_name_custom}):"
  avail_set = compute.availability_sets.create(
    name: managed_as_name_custom,
    location: Config.location,
    resource_group: resource_group_name,
    tags: tags,
    platform_fault_domain_count: 2,
    platform_update_domain_count: 10,
    use_managed_disk: true
  )
  name = avail_set.name
  fault_domains = avail_set.platform_fault_domain_count
  update_domains = avail_set.platform_update_domain_count
  puts "Created availability set! [#{name}] => { fd: #{fault_domains}, ud: #{update_domains} }"

  ########################################################################################################################
  ######################                       List Availability Sets                               ######################
  ########################################################################################################################

  puts 'List availability sets:'
  compute.availability_sets(resource_group: resource_group_name).each do |availability_set|
    puts availability_set.name
  end

  ########################################################################################################################
  ######################                       Get and Delete Availability Set                      ######################
  ########################################################################################################################

  puts 'Get and delete availability sets:'

  avail_set = compute.availability_sets.get(resource_group_name, unmanaged_as_name_default)
  puts "Get availability set     : #{avail_set.name}"
  puts "Deleted availability set : #{avail_set.destroy}"

  avail_set = compute.availability_sets.get(resource_group_name, unmanaged_as_name_custom)
  puts "Get availability set     : #{avail_set.name}"
  puts "Deleted availability set : #{avail_set.destroy}"

  avail_set = compute.availability_sets.get(resource_group_name, managed_as_name_default)
  puts "Get availability set     : #{avail_set.name}"
  puts "Deleted availability set : #{avail_set.destroy}"

  avail_set = compute.availability_sets.get(resource_group_name, managed_as_name_custom)
  puts "Get availability set     : #{avail_set.name}"
  puts "Deleted availability set : #{avail_set.destroy}"

  ########################################################################################################################
  ######################                                   Clean Up                                 ######################
  ########################################################################################################################

  rg = rs.resource_groups.get(resource_group_name)
  rg.destroy

  puts 'Integration test for availability set ran successfully!'
rescue
  puts 'Integration Test for availability set is failing!!!'
  resource_group.destroy unless resource_group.nil?
end

require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file(File.expand_path('credentials/azure.yml', __dir__))

resource = Fog::Resources::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

dns = Fog::DNS::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

begin
  resource_group = resource.resource_groups.create(
    name: 'TestRG-RS',
    location: Config.location
  )

  dns.zones.create(
    name: 'test-zone.com',
    location: 'global',
    resource_group: 'TestRG-RS'
  )

  ########################################################################################################################
  ######################                      Check Record Set Exists?                              ######################
  ########################################################################################################################

  flag = dns.record_sets.check_record_set_exists('TestRG-RS', 'TestRS1', 'test-zone.com', 'CNAME')
  puts "Record set doesn't exist." unless flag

  ########################################################################################################################
  ######################                      Create CNAME Type Record Set in a Zone                 ######################
  ########################################################################################################################

  record_set = dns.record_sets.create(
    name: 'TestRS1',
    resource_group: 'TestRG-RS',
    zone_name: 'test-zone.com',
    records: ['test.fog.com'],
    type: 'CNAME',
    ttl: 60
  )
  puts "Created CNAME type record set: #{record_set.inspect}"

  ########################################################################################################################
  ######################                        Create A Type Record Set in a Zone                   ######################
  ########################################################################################################################

  record_set = dns.record_sets.create(
    name: 'TestRS2',
    resource_group: 'TestRG-RS',
    zone_name: 'test-zone.com',
    records: %w(1.2.3.4 1.2.3.3),
    type: 'A',
    ttl: 60
  )
  puts "Created A type record set: #{record_set.inspect}"

  ########################################################################################################################
  ######################                Get And Destroy CNAME Type Record Set in a Zone             ######################
  ########################################################################################################################

  record_set = dns.record_sets.get('TestRG-RS', 'TestRS1', 'test-zone.com', 'CNAME')
  puts "Get CNAME Type record set: #{record_set.inspect}"
  record_set.destroy

  ########################################################################################################################
  ######################                  Get And Destroy A Type Record Set in a Zone               ######################
  ########################################################################################################################

  record_set = dns.record_sets.get('TestRG-RS', 'TestRS2', 'test-zone.com', 'A')
  puts "Get A Type record set: #{record_set.inspect}"

  ########################################################################################################################
  ######################                               Update a Record Set                          ######################
  ########################################################################################################################

  record_set.update_ttl(80)
  puts 'Updated TTL of record set'

  ########################################################################################################################
  ######################                               Add an A-type Record                         ######################
  ########################################################################################################################

  record_set.add_a_type_record('1.2.3.8')
  puts 'Added A type record in record set'

  ########################################################################################################################
  ######################                            Remove an A-type Record                         ######################
  ########################################################################################################################

  record_set.remove_a_type_record('1.2.3.8')
  puts 'Removed A type record in record set'

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  puts "Deleted record set: #{record_set.destroy}"
  zone = dns.zones.get('TestRG-RS', 'test-zone.com')
  zone.destroy

  rg = resource.resource_groups.get('TestRG-RS')
  rg.destroy
  puts 'Integration Test for record set ran successfully'
rescue
  puts 'Integration Test for record set is failing'
  resource_group.destroy unless resource_group.nil?
end

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

dns = Fog::DNS.new(
  provider: 'AzureRM',
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
    name: 'TestRG-ZN',
    location: Config.location
  )

  ########################################################################################################################
  ######################                            Check Zone Exists?                              ######################
  ########################################################################################################################

  flag = dns.zones.check_zone_exists('TestRG-ZN', 'test-zone.com')
  puts "Zone doesn't exist." unless flag

  ########################################################################################################################
  ######################                                Create Zone                                 ######################
  ########################################################################################################################

  zone = dns.zones.create(
    name: 'test-zone.com',
    location: 'global',
    resource_group: 'TestRG-ZN'
  )
  puts "Created zone: #{zone.name}"

  ########################################################################################################################
  ######################                    Get All Zones in a Subscription                         ######################
  ########################################################################################################################

  puts 'List zones in a subscription:'
  dns.zones.each do |z|
    puts "Resource Group:#{z.resource_group} name:#{z.name}"
  end

  ########################################################################################################################
  ######################               Get and Destroy Zone in a Resource Group                     ######################
  ########################################################################################################################

  zone = dns.zones.get('TestRG-ZN', 'test-zone.com')
  puts "Get zone: #{zone.name}"
  puts "Deleted zone: #{zone.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  rg = rs.resource_groups.get('TestRG-ZN')
  rg.destroy
  puts 'Integration Test for zone ran successfully'
rescue
  puts 'Integration Test for zone is failing'
  resource_group.destroy unless resource_group.nil?
end

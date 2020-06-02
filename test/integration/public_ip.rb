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
    name: 'TestRG-PB',
    location: Config.location
  )

  ########################################################################################################################
  ######################                               Check PublicIP exists                        ######################
  ########################################################################################################################

  flag = network.public_ips.check_public_ip_exists('TestRG-PB', 'mypubip')
  puts "Public IP doesn't exist." unless flag

  ########################################################################################################################
  ######################                               Create Public IP                             ######################
  ########################################################################################################################

  public_ip = network.public_ips.create(
    name: 'mypubip',
    resource_group: 'TestRG-PB',
    location: Config.location,
    public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
    tags: { key: 'value' }
  )
  puts "Created public ip: #{public_ip.name}"

  ########################################################################################################################
  ######################                           Get and Update Public IP                         ######################
  ########################################################################################################################

  pubip = network.public_ips.get('TestRG-PB', 'mypubip')
  puts "Get public ip: #{pubip.name}"
  pubip.update(
      public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
      idle_timeout_in_minutes: '10',
      domain_name_label: 'newdomainlabel'
  )
  puts 'Updated public ip'

  ########################################################################################################################
  ######################                           Get and Delete Public IP                         ######################
  ########################################################################################################################

  pubip = network.public_ips.get('TestRG-PB', 'mypubip')
  puts "Deleted public ip: #{pubip.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  rg = rs.resource_groups.get('TestRG-PB')
  rg.destroy
rescue
  puts 'Integration Test for public ip is failing'
  resource_group.destroy unless resource_group.nil?
end

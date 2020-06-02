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
    name: 'TestRG-NSR',
    location: Config.location
  )

  ########################################################################################################################
  ######################                          Create Network Security Group                     ######################
  ########################################################################################################################

  network.network_security_groups.create(
    name: 'testGroup',
    resource_group: 'TestRG-NSR',
    location: Config.location
  )

  ########################################################################################################################
  ######################                  Check Network Security Rule Exists?                       ######################
  ########################################################################################################################

  flag = network.network_security_rules.check_net_sec_rule_exists('TestRG-NSR', 'testGroup', 'testRule')
  puts "Network Security Rule doesn't exist." unless flag

  ########################################################################################################################
  ######################                          Create Network Security Rule                      ######################
  ########################################################################################################################

  network_security_rule = network.network_security_rules.create(
    name: 'testRule',
    resource_group: 'TestRG-NSR',
    protocol: Fog::ARM::Network::Models::SecurityRuleProtocol::Tcp,
    network_security_group_name: 'testGroup',
    source_port_range: '22',
    destination_port_range: '22',
    source_address_prefix: '0.0.0.0/0',
    destination_address_prefix: '0.0.0.0/0',
    access: Fog::ARM::Network::Models::SecurityRuleAccess::Allow,
    priority: '100',
    direction: Fog::ARM::Network::Models::SecurityRuleDirection::Inbound
  )
  puts "Created network security rule: #{network_security_rule.name}"

  ########################################################################################################################
  ######################                        List Network Security Rules                         ######################
  ########################################################################################################################

  network_security_rules = network.network_security_rules(resource_group: 'TestRG-NSR',
                                                          network_security_group_name: 'testGroup')
  puts 'List network security rules:'
  network_security_rules.each do |a_network_security_rule|
    puts a_network_security_rule.name
  end

  ########################################################################################################################
  ######################                          Get Network Security Rule                         ######################
  ########################################################################################################################

  nsr = network.network_security_rules.get('TestRG-NSR', 'testGroup', 'testRule')
  puts "Get network_security_rule: #{nsr.name}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  puts "Deleted network_security_rule: #{nsr.destroy}"
  nsg = network.network_security_groups.get('TestRG-NSR', 'testGroup')
  nsg.destroy
  rg = rs.resource_groups.get('TestRG-NSR')
  rg.destroy
  puts 'Integration Test for network_security_rule ran successfully'
rescue
  puts 'Integration Test for network_security_rule is failing'
  resource_group.destroy unless resource_group.nil?
end

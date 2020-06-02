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
    name: 'TestRG-NSG',
    location: Config.location
  )

  ########################################################################################################################
  ######################                  Check Network Security Group Exists?                      ######################
  ########################################################################################################################

  flag = network.network_security_groups.check_net_sec_group_exists('TestRG-NSG', 'testGroup')
  puts "Network Security Group doesn't exist." unless flag

  ########################################################################################################################
  ######################                          Create Network Security Group                     ######################
  ########################################################################################################################

  network_security_group = network.network_security_groups.create(
    name: 'testGroup',
    resource_group: 'TestRG-NSG',
    location: Config.location,
    security_rules: [{
      name: 'testRule',
      protocol: Fog::ARM::Network::Models::SecurityRuleProtocol::Tcp,
      source_port_range: '22',
      destination_port_range: '22',
      source_address_prefix: '0.0.0.0/0',
      destination_address_prefix: '0.0.0.0/0',
      access: Fog::ARM::Network::Models::SecurityRuleAccess::Allow,
      priority: '100',
      direction: Fog::ARM::Network::Models::SecurityRuleDirection::Inbound
    }],
    tags: { key: 'value' }
  )
  puts "Created network security group: #{network_security_group.name}"

  ########################################################################################################################
  ######################                    Get and Update Network Security Group                  ######################
  ########################################################################################################################

  nsg = network.network_security_groups.get('TestRG-NSG', 'testGroup')
  puts "Get network security group: #{nsg.name}"
  nsg.update_security_rules(
    security_rules:
      [
        {
          name: 'testRule',
          protocol: Fog::ARM::Network::Models::SecurityRuleProtocol::Tcp,
          source_port_range: '*',
          destination_port_range: '22',
          source_address_prefix: '0.0.0.0/0',
          destination_address_prefix: '0.0.0.0/0',
          access: Fog::ARM::Network::Models::SecurityRuleAccess::Allow,
          priority: '100',
          direction: Fog::ARM::Network::Models::SecurityRuleDirection::Inbound
        }
      ]
  )
  puts 'Updated security rules of network security group'

  ########################################################################################################################
  ######################                        List Network Security Group                         ######################
  ########################################################################################################################

  network_security_groups = network.network_security_groups(resource_group: 'TestRG-NSG')
  puts 'List network security groups:'
  network_security_groups.each do |a_network_security_group|
    puts a_network_security_group.name
  end

  ########################################################################################################################
  ######################                    Add and Remove Network Security Rules                  ######################
  ########################################################################################################################

  nsg.add_security_rules(
    [
      {
        name: 'testRule2',
        protocol: Fog::ARM::Network::Models::SecurityRuleProtocol::Tcp,
        source_port_range: '22',
        destination_port_range: '22',
        source_address_prefix: '0.0.0.0/0',
        destination_address_prefix: '0.0.0.0/0',
        access: Fog::ARM::Network::Models::SecurityRuleAccess::Allow,
        priority: '102',
        direction: Fog::ARM::Network::Models::SecurityRuleDirection::Inbound
      }
    ]
  )
  puts 'Added security rules in network security group'

  nsg.remove_security_rule('testRule')
  puts 'Removed security rules from network security group'

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  puts "Deleted network security group: #{nsg.destroy}"
  rg = rs.resource_groups.get('TestRG-NSG')
  rg.destroy
  puts 'Integration Test for network security group ran successfully'
rescue
  puts 'Integration Test for network security group is failing'
  resource_group.destroy unless resource_group.nil?
end

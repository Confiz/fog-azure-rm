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

application_gateway = Fog::ApplicationGateway::AzureRM.new(
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
######################                               Resource names                                #####################
########################################################################################################################

time = current_time
resource_group_name = "TestRG-AG-#{time}"
virtual_network_name = "Vnet#{time}"
subnet_name = "Sub#{time}"
public_ip_name = "Pip#{time}"
app_gateway_name = "AG#{time}"

########################################################################################################################
######################                                 Prerequisites                               #####################
########################################################################################################################

begin
  resource_group = resource.resource_groups.create(
    name: resource_group_name,
    location: Config.location
  )

  network.virtual_networks.create(
    name: virtual_network_name,
    location: Config.location,
    resource_group: resource_group_name,
    dns_servers: %w(10.1.0.0 10.2.0.0),
    address_prefixes: %w(10.1.0.0/16 10.2.0.0/16)
  )

  network.subnets.create(
    name: subnet_name,
    resource_group: resource_group_name,
    virtual_network_name: virtual_network_name,
    address_prefix: '10.2.0.0/24'
  )

  network.public_ips.create(
    name: public_ip_name,
    resource_group: resource_group_name,
    location: Config.location,
    public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic
  )

  ########################################################################################################################
  ######################                            Check for Application Gateway                   ######################
  ########################################################################################################################

  flag = application_gateway.gateways.check_application_gateway_exists(resource_group_name, app_gateway_name)
  puts "Application Gateway doesn't exist." unless flag

  #######################################################################################################################
  #####################                          Create Application Gateway                        ######################
  #######################################################################################################################

  tags = { key1: 'value1', key2: 'value2' }

  app_gateway = application_gateway.gateways.create(
    name: app_gateway_name,
    location: Config.location,
    resource_group: resource_group_name,
    tags: tags,
    sku_name: 'Standard_Medium',
    sku_tier: 'Standard',
    sku_capacity: '2',
    gateway_ip_configurations: [
      {
        name: 'gatewayIpConfigName',
        subnet_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourcegroups/#{resource_group_name}/providers/Microsoft.Network/virtualNetworks/#{virtual_network_name}/subnets/#{subnet_name}"
      }
    ],
    frontend_ip_configurations: [
      {
        name: 'frontendIpConfig',
        private_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
        public_ip_address_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourcegroups/#{resource_group_name}/providers/Microsoft.Network/publicIPAddresses/#{public_ip_name}",
        private_ip_address: '10.0.1.5'
      }
    ],
    frontend_ports: [
      {
        name: 'frontendPort',
        port: 65_502
      }
    ],
    backend_address_pools: [
      {
        name: 'backendAddressPool',
        ip_addresses: [
          {
            ipAddress: '10.0.1.6'

          }
        ]
      }
    ],
    backend_http_settings_list: [
      {
        name: 'gateway_settings',
        port: 80,
        protocol: 'Http',
        cookie_based_affinity: 'Enabled',
        request_timeout: '30'
      }
    ],
    http_listeners: [
      {
        name: 'gateway_listener',
        frontend_ip_config_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{resource_group_name}/providers/Microsoft.Network/applicationGateways/#{app_gateway_name}/frontendIPConfigurations/frontendIpConfig",
        frontend_port_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{resource_group_name}/providers/Microsoft.Network/applicationGateways/#{app_gateway_name}/frontendPorts/frontendPort",
        protocol: 'Http',
        host_name: '',
        require_server_name_indication: 'false'
      }
    ],
    request_routing_rules: [
      {
        name: 'gateway_request_route_rule',
        type: 'Basic',
        http_listener_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{resource_group_name}/providers/Microsoft.Network/applicationGateways/#{app_gateway_name}/httpListeners/gateway_listener",
        backend_address_pool_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{resource_group_name}/providers/Microsoft.Network/applicationGateways/#{app_gateway_name}/backendAddressPools/backendAddressPool",
        backend_http_settings_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/#{resource_group_name}/providers/Microsoft.Network/applicationGateways/#{app_gateway_name}/backendHttpSettingsCollection/gateway_settings",
        url_path_map: ''
      }
    ]
  )
  puts "Created application gateway #{app_gateway.name}"

  ########################################################################################################################
  ######################                      Get Application Gateway                   ######################
  ########################################################################################################################

  app_gateway = application_gateway.gateways.get(resource_group_name, app_gateway_name)
  puts "Get application gateway: #{app_gateway.name}"

  ########################################################################################################################
  ######################                Update sku attributes (Name and Capacity)                #########################
  ########################################################################################################################

  app_gateway.update_sku('Standard_Small', '1')
  puts 'Updated application gateway sku'

  ########################################################################################################################
  ######################                       Stop Application Gateway                          #########################
  ########################################################################################################################

  app_gateway.stop
  puts 'Application Gateway stopped!'

  ########################################################################################################################
  ######################              Update gateway ip configuration (Subnet id)                #########################
  ########################################################################################################################

  subnet_id = network.subnets.create(
    name: "#{subnet_name}1",
    resource_group: resource_group_name,
    virtual_network_name: virtual_network_name,
    address_prefix: '10.1.0.0/24'
  ).id

  app_gateway.update_gateway_ip_configuration(subnet_id)
  puts 'Updated Application Gateway ip configuration'

  ########################################################################################################################
  ######################                       Start Application Gateway                         #########################
  ########################################################################################################################

  app_gateway.start
  puts 'Application Gateway started!'

  ########################################################################################################################
  ######################                          Add/Remove Frontend ports                      #########################
  ########################################################################################################################

  app_gateway.add_frontend_port(name: 'frontendPort1', port: 80)
  puts 'Added Frontend port in application gateway'

  app_gateway.remove_frontend_port(name: 'frontendPort1', port: 80)
  puts 'Removed Frontend port in application gateway'

  #######################################################################################################################
  #####################                             Add/Remove Probes                           #########################
  #######################################################################################################################

  app_gateway.add_probe(
    name: 'Probe1',
    protocol: 'http',
    host: 'localhost',
    path: '/fog-test',
    interval: 60,
    timeout: 300,
    unhealthy_threshold: 5
  )
  puts 'Added probe in application gateway'

  app_gateway.remove_probe(
    name: 'Probe1',
    protocol: 'http',
    host: 'localhost',
    path: '/fog-test',
    interval: 60,
    timeout: 300,
    unhealthy_threshold: 5
  )
  puts 'Removed probe in application gateway'

  ########################################################################################################################
  ######################                            Destroy Application Gateway                     ######################
  ########################################################################################################################

  puts "Deleted application gateway: #{app_gateway.destroy}"

  ########################################################################################################################
  ######################                                   CleanUp                                  ######################
  ########################################################################################################################

  pubip = network.public_ips.get(resource_group_name, public_ip_name)
  pubip.destroy

  vnet = network.virtual_networks.get(resource_group_name, virtual_network_name)
  vnet.destroy

  resource_group = resource.resource_groups.get(resource_group_name)
  resource_group.destroy

  puts 'Integration Test for application gateway ran successfully'
rescue
  puts 'Integration Test for application gateway is failing'
  resource_group.destroy unless resource_group.nil?
end

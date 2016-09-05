if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
    command_name 'Minitest'
  end
end

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'minitest/autorun'
$LOAD_PATH.unshift(File.expand_path '../../lib', __FILE__)
require File.expand_path '../../lib/fog/azurerm', __FILE__
require File.expand_path '../test/api_stub', __FILE__
def credentials
  {
    tenant_id: '<TENANT-ID>',
    client_id: '<CLIENT-ID>',
    client_secret: '<CLIENT-SECRET>',
    subscription_id: '<SUBSCRIPTION-ID>'
  }
end

def storage_account_credentials
  {
    azure_storage_account_name: 'mockaccount',
    azure_storage_access_key: 'YWNjZXNzLWtleQ=='
  }
end

def server(service)
  Fog::Compute::AzureRM::Server.new(
    name: 'fog-test-server',
    location: 'West US',
    resource_group: 'fog-test-rg',
    vm_size: 'Basic_A0',
    storage_account_name: 'shaffanstrg',
    username: 'shaffan',
    password: 'Confiz=123',
    disable_password_authentication: false,
    network_interface_card_id: '/subscriptions/########-####-####-####-############/resourceGroups/shaffanRG/providers/Microsoft.Network/networkInterfaces/testNIC',
    publisher: 'Canonical',
    offer: 'UbuntuServer',
    sku: '14.04.2-LTS',
    version: 'latest',
    platform: 'Windows',
    service: service
  )
end

def availability_set(service)
  Fog::Compute::AzureRM::AvailabilitySet.new(
    name: 'availability-set',
    location: 'West US',
    resource_group: 'fog-test-rg',
    service: service
  )
end

def resource_group(service)
  Fog::Resources::AzureRM::ResourceGroup.new(
    name: 'fog-test-rg',
    location: 'West US',
    service: service
  )
end

def deployment(service)
  Fog::Resources::AzureRM::Deployment.new(
    name: 'fog-test-deployment',
    resource_group: 'fog-test-rg',
    template_link: 'https://test.com/template.json',
    parameters_link: 'https://test.com/parameters.json',
    service: service
  )
end

def storage_account(service)
  Fog::Storage::AzureRM::StorageAccount.new(
    name: 'storage-account',
    location: 'West US',
    resource_group: 'fog-test-rg',
    service: service
  )
end

def standard_lrs(service)
  Fog::Storage::AzureRM::StorageAccount.new(
    name: 'storage-account',
    location: 'West US',
    resource_group: 'fog-test-rg',
    sku_name: 'Other',
    replication: 'LRS',
    service: service
  )
end

def standard_check_for_invalid_replications(service)
  Fog::Storage::AzureRM::StorageAccount.new(
    name: 'storage-account',
    location: 'West US',
    resource_group: 'fog-test-rg',
    sku_name: 'Standard',
    replication: 'HGDKS',
    service: service
  )
end

def premium_check_for_invalid_replications(service)
  Fog::Storage::AzureRM::StorageAccount.new(
    name: 'storage-account',
    location: 'West US',
    resource_group: 'fog-test-rg',
    sku_name: 'Premium',
    replication: 'HGDKS',
    service: service
  )
end

def storage_container(service)
  Fog::Storage::AzureRM::Container.new(
    name: 'storage-test-container',
    last_modified: 'Tue, 04 Aug 2015 06:01:08 GMT',
    etag: '0x8D29C92176C8352',
    lease_status: 'unlocked',
    lease_state: 'available',
    lease_duration: nil,
    metadata: {
      'key1' => 'value1',
      'key2' => 'value2'
    },
    public_access_level: nil,
    service: service
  )
end

def public_ip(service)
  Fog::Network::AzureRM::PublicIp.new(
    name: 'fog-test-public-ip',
    resource_group: 'fog-test-rg',
    location: 'West US',
    public_ip_allocation_method: 'Dynamic',
    service: service
  )
end

def subnet(service)
  Fog::Network::AzureRM::Subnet.new(
    name: 'fog-test-subnet',
    resource_group: 'fog-test-rg',
    virtual_network_name: 'vnet1',
    address_prefix: '10.0.0.0/24',
    network_security_group_id: '/subscriptions/{guid}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkSecurityGroups/myNSG1',
    route_table_id: '/subscriptions/{guid}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/routeTables/myRT1',
    service: service
  )
end

def virtual_network(service)
  Fog::Network::AzureRM::VirtualNetwork.new(
    name:             'fog-test-virtual-network',
    location:         'westus',
    resource_group:   'fog-test-rg',
    subnets:          [{
      name: 'fog-test-subnet',
      address_prefix: '10.1.0.0/24',
      network_security_group_id: '/subscriptions/{guid}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkSecurityGroups/myNSG1',
      route_table_id: '/subscriptions/{guid}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/routeTables/myRT1'
    }],
    dns_servers:       ['10.1.0.0', '10.2.0.0'],
    address_prefixes:  ['10.1.0.0/16', '10.2.0.0/16'],
    service: service
  )
end

def network_interface(service)
  Fog::Network::AzureRM::NetworkInterface.new(
    name: 'fog-test-network-interface',
    location: 'West US',
    resource_group: 'fog-test-rg',
    subnet_id: '/subscriptions/########-####-####-####-############/resourceGroups/fog-test-rg/providers/Microsoft.Network/virtualNetworks/fog-test-virtual-network/subnets/fog-test-subnet',
    public_ip_address_id: '/subscriptions/########-####-####-####-############/resourceGroups/fog-test-rg/providers/Microsoft.Network/publicIPAddresses/fog-test-public-ip',
    network_security_group_id: '/subscriptions/########-####-####-####-############/resourceGroups/fog-test-rg/providers/Microsoft.Network/networkSecurityGroups/fog-test-nsg',
    ip_configuration_name: 'fog-test-ip-configuration',
    private_ip_allocation_method: 'fog-test-private-ip-allocation-method',
    properties: nil,
    service: service
  )
end

def load_balancer(service)
  Fog::Network::AzureRM::LoadBalancer.new(
    name: 'lb',
    resource_group: 'fogRM-rg',
    location: 'westus',
    frontend_ip_configurations:
      [
        {
          name: 'fic',
          private_ipallocation_method: 'Dynamic',
          public_ipaddress_id: '/subscriptions/########-####-####-####-############/resourcegroups/fogRM-rg/providers/Microsoft.Network/publicIPAddresses/pip',
          subnet_id: '/subscriptions/########-####-####-####-############/resourcegroups/fogRM-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/sb1'
        }
      ],
    backend_address_pool_names:
      [
        'pool1'
      ],
    load_balancing_rules:
      [
        {
          name: 'lb_rule_1',
          frontend_ip_configuration_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/loadBalancers/lb/frontendIPConfigurations/fic',
          backend_address_pool_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/loadBalancers/lb/backendAddressPools/pool1',
          protocol: 'Tcp',
          frontend_port: '80',
          backend_port: '8080',
          enable_floating_ip: false,
          idle_timeout_in_minutes: 4,
          load_distribution: 'Default'
        }
      ],
    inbound_nat_rules:
      [
        {
          name: 'RDP-Traffic',
          frontend_ip_configuration_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/loadBalancers/lb/frontendIPConfigurations/fic',
          protocol: 'Tcp',
          frontend_port: 3389,
          backend_port: 3389
        }
      ],
    probes:
      [
        {
          name: 'probe1',
          protocol: 'Tcp',
          port: 8080,
          request_path: 'myprobeapp1/myprobe1.svc',
          interval_in_seconds: 5,
          number_of_probes: 16
        }
      ],
    inbound_nat_pools:
      [
        {
          name: 'RDPForVMSS1',
          protocol: 'Tcp',
          frontend_port_range_start: 500,
          frontend_port_range_end: 505,
          backend_port: 3389
        }
      ],
    service: service
  )
end

def zone(service)
  Fog::DNS::AzureRM::Zone.new(
    name: 'fog-test-zone.com',
    id: '/subscriptions/########-####-####-####-############/resourceGroups/fog-test-rg/providers/Microsoft.Network/dnszones/fog-test-zone.com',
    resource_group: 'fog-test-rg',
    service: service
  )
end

def record_set(service)
  Fog::DNS::AzureRM::RecordSet.new(
    name: 'fog-test-record_set',
    resource_group: 'fog-test-rg',
    zone_name: 'fog-test-zone.com',
    records: %w(1.2.3.4 1.2.3.3),
    type: 'A',
    ttl: 60,
    service: service
  )
end

def record_set_cname(service)
  Fog::DNS::AzureRM::RecordSet.new(
    name: 'fog-test-record_set',
    resource_group: 'fog-test-rg',
    zone_name: 'fog-test-zone.com',
    records: %w(1.2.3.4 1.2.3.3),
    type: 'CNAME',
    ttl: 60,
    service: service
  )
end

def network_security_group(service)
  Fog::Network::AzureRM::NetworkSecurityGroup.new(
    name: 'fog-test-nsg',
    resource_group: 'fog-test-rg',
    location: 'West US',
    security_rules: [{
      name: 'fog-test-rule',
      protocol: 'tcp',
      source_port_range: '22',
      destination_port_range: '22',
      source_address_prefix: '0.0.0.0/0',
      destination_address_prefix: '0.0.0.0/0',
      access: 'Allow',
      priority: '100',
      direction: 'Inbound'
    }],
    service: service
  )
end

def network_security_rule(service)
  Fog::Network::AzureRM::NetworkSecurityRule.new(
    name: 'fog-test-nsr',
    resource_group: 'fog-test-rg',
    network_security_group_name: 'fog-test-nsr',
    protocol: 'tcp',
    source_port_range: '22',
    destination_port_range: '22',
    source_address_prefix: '0.0.0.0/0',
    destination_address_prefix: '0.0.0.0/0',
    access: 'Allow',
    priority: '100',
    direction: 'Inbound',
    service: service
  )
end

def gateway(service)
  Fog::ApplicationGateway::AzureRM::Gateway.new(
    name: 'gateway',
    location: 'eastus',
    resource_group: 'fogRM-rg',
    sku_name: 'Standard_Medium',
    sku_tier: 'Standard',
    sku_capacity: '2',
    gateway_ip_configurations:
      [
        {
          name: 'gatewayIpConfigName',
          subnet_id: '/subscriptions/########-####-####-####-############/resourcegroups/fogRM-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnetName'
        }
      ],
    ssl_certificates:
      [
        {
          name: 'certificate',
          data: 'data',
          password: '123',
          public_cert_data: 'MIIDiDCCAnACCQCwYkR0Mxy+QTANBgkqhkiG9w0BAQUFADCBhTELMAkGA1UEBhMCUEsxDzANBgNVBAgTBlB1bmphYjEPMA0GA1UEBxMGTGFob3JlMQ8wDQYDVQQKEwZDb25maXoxDDAKBgNVBAsTA0RldjEPMA0GA1UEAxMGaGFpZGVyMSQwIgYJKoZIhvcNAQkBFhVoYWlkZXIuYWxpQGNvbmZpei5jb20wHhcNMTYwMzAyMTE0NTM2WhcNMTcwMzAyMTE0NTM2WjCBhTELMAkGA1UEBhMCUEsxDzANBgNVBAgTBlB1bmphYjEPMA0GA1UEBxMGTGFob3JlMQ8wDQYDVQQKEwZDb25maXoxDDAKBgNVBAsTA0RldjEPMA0GA1UEAxMGaGFpZGVyMSQwIgYJKoZIhvcNAQkBFhVoYWlkZXIuYWxpQGNvbmZpei5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCuJrPbvOG+4oXQRamkOALlpdK98m+atJue9zOcCCagY8IJI4quYL13d8VItmrZf7erA+siqpYlWEuk1+lmmUY7T4AWAL8mXeR2vc7hWF601WDUjeVPK19+IcC8emMLOlBpvjXC9nbvADLQuR0PGitfjCqFoG66EOqJmLDNBsyHWmy+qhb8J4WXitruNAJDPe/20h6L23vD6z4tvwBjh4zkrfskGlKCNcAuvG1NI0FAS8261Jvs3lf+8oFyI+oSXGtknrkeQv3PbXyeEe3KO5a/M61Uebo04Uwd4yCvdu6H0sF+YYA4bfFdanuFmrZvf9cZSwknQid+vOdzyGkTHTPFAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAKtPhYpfvn5OxP+BcChsWaQA4KZQj0THGdiAjHsvfjsgteFvhkzqZBkhKYtsAWV5tB5/GDl+o4c6PQJ2/TXhOJn3pSNaUzrCJIGtKS5DknbqTQxCwVlxyBtPHLAYWqKcPMlH282rw3VY0OYTL96XOgZ/WZjcN6A7ku+uWsNCql443FoWL+N3Gpaab45OyIluFUOH+yc0ToHNlP3iOpI3rVpi2xwmGrSyUKsGUma3nrBq7TWjkDE1E+oJoybaMNZzgXGIPSJC1HYIF1U8GSoFkZpAFxXecD0FinXWDRwUP6K54iti3i6a/Ox73WhwfI4mVCqsOy1WYWtKYhMVe6Kj4Nw='
        }
      ],
    frontend_ip_configurations:
      [
        {
          name: 'frontendIpConfig',
          private_ip_allocation_method: 'Dynamic',
          public_ip_address_id: '/subscriptions/########-####-####-####-############/resourcegroups/fogRM-rg/providers/Microsoft.Network/publicIPAddresses/publicIp',
          private_ip_address: '10.0.1.5'
        }
      ],
    frontend_ports:
      [
        {
          name: 'frontendPort',
          port: 443
        }
      ],
    probes:
      [
        {
          name: 'probe1',
          protocol: 'tcp',
          host: 'localhost',
          path: '/usr/',
          interval: 30,
          timeout: 20,
          unhealthy_threshold: 20
        }
      ],
    backend_address_pools:
      [
        {
          name: 'backendAddressPool',
          ip_addresses: [
            {
              ipAddress: '10.0.1.6'
            }
          ]
        }
      ],
    backend_http_settings_list:
      [
        {
          name: 'gateway_settings',
          port: 80,
          protocol: 'Http',
          cookie_based_affinity: 'Enabled',
          request_timeout: '30',
          probe: ''
        }
      ],
    http_listeners:
      [
        {
          name: 'gateway_listener',
          frontend_ip_config_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/frontendIPConfigurations/frontend_ip_config',
          frontend_port_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/frontendPorts/gateway_front_port',
          protocol: 'Https',
          host_name: '',
          ssl_certificate_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/sslCertificates/ssl_certificate',
          require_server_name_indication: 'false'
        }
      ],
    url_path_maps:
      [
        {
          name: 'map1',
          default_backend_address_pool_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/backendAddressPools/AG-BackEndAddressPool',
          default_backend_http_settings_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/backendHttpSettingsCollection/gateway_settings',
          path_rules: [
            {
              backend_address_pool_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/backendAddressPools/AG-BackEndAddressPool',
              backend_http_settings_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/backendHttpSettingsCollection/gateway_settings',
              paths: [
                %w('/usr', '/etc')
              ]
            }
          ]
        }
      ],
    request_routing_rules:
      [
        {
          name: 'gateway_request_route_rule',
          type: 'Basic',
          http_listener_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/httpListeners/gateway_listener',
          backend_address_pool_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/backendAddressPools/AG-BackEndAddressPool',
          backend_http_settings_id: '/subscriptions/########-####-####-####-############/resourceGroups/fogRM-rg/providers/Microsoft.Network/applicationGateways/gateway/backendHttpSettingsCollection/gateway_settings',
          url_path_map: ''
        }
      ],
    service: service
  )
end

def traffic_manager_end_point(service)
  Fog::TrafficManager::AzureRM::TrafficManagerEndPoint.new(
    name: 'fog-test-end-point',
    traffic_manager_profile_name: 'fog-test-profile',
    resource_group: 'fog-test-rg',
    type: 'external',
    target: 'test.com',
    endpoint_location: 'West US',
    service: service
  )
end

def traffic_manager_profile(service)
  Fog::TrafficManager::AzureRM::TrafficManagerProfile.new(
    name: 'fog-test-profile',
    resource_group: 'fog-test-rg',
    traffic_routing_method: 'Performance',
    relative_name: 'fog-test-app',
    ttl: '30',
    protocol: 'http',
    port: '80',
    path: '/monitorpage.aspx',
    service: service
  )
end

def virtual_network_gateway(service)
  Fog::Network::AzureRM::VirtualNetworkGateway.new(
    name: 'testNetworkGateway',
    location: 'eastus',
    tags: {
      key1: 'value1',
      key2: 'value2'
    },
    resource_group: 'learn_fog',
    sku_name: 'HighPerformance',
    sku_tier: 'Standard',
    sku_capacity: 100,
    gateway_type: 'ExpressRoute',
    enable_bgp: true,
    gateway_size: 'Default',
    vpn_client_address_pool: ['vpnClientAddressPoolPrefix'],
    default_sites: ['mysite1'],
    gateway_default_site: '/subscriptions/{subscription-id}/resourceGroups/fog-rg/providers/microsoft.network/localNetworkGateways/{local-network-gateway-name}',
    service: service
  )
end

def express_route_circuit(service)
  Fog::Network::AzureRM::ExpressRouteCircuit.new(
    name: 'testCircuit',
    location: 'eastus',
    resource_group: 'HaiderRG',
    tags: {
      key1: 'value1'
    },
    sku_name: 'Standard_MeteredData',
    sku_tier: 'Standard',
    sku_family: 'MeteredData',
    service_provider_name: 'Telenor',
    peering_location: 'London',
    bandwidth_in_mbps: 100,
    peerings: [
      {
        name: 'AzurePublicPeering',
        peering_type: 'AzurePublicPeering',
        peer_asn: 100,
        primary_peer_address_prefix: '192.168.1.0/30',
        secondary_peer_address_prefix: '192.168.2.0/30',
        vlan_id: 200
      }
    ],
    service: service
  )
end

def express_route_circuit_peering(service)
  Fog::Network::AzureRM::ExpressRouteCircuitPeering.new(
    name: 'AzurePublicPeering',
    circuit_name: 'testCircuit',
    resource_group: 'HaiderRG',
    peering_type: 'AzurePublicPeering',
    peer_asn: 100,
    primary_peer_address_prefix: '192.168.1.0/30',
    secondary_peer_address_prefix: '192.168.2.0/30',
    vlan_id: 200,
    service: service
  )
end

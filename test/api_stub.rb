# Module for API Stub
module ApiStub
  module Models
    # Load test Compute models
    module Compute
      autoload :Server, File.expand_path('api_stub/models/compute/server', __dir__)
      autoload :AvailabilitySet, File.expand_path('api_stub/models/compute/availability_set', __dir__)
      autoload :VirtualMachineExtension, File.expand_path('api_stub/models/compute/virtual_machine_extension', __dir__)
      autoload :ManagedDisk, File.expand_path('api_stub/models/compute/managed_disk', __dir__)
      autoload :Snapshot, File.expand_path('api_stub/models/compute/snapshot', __dir__)
    end

    # Load test Resources models
    module Resources
      autoload :ResourceGroup, File.expand_path('api_stub/models/resources/resource_group', __dir__)
      autoload :Deployment, File.expand_path('api_stub/models/resources/deployment', __dir__)
      autoload :Resource, File.expand_path('api_stub/models/resources/resource', __dir__)
    end

    # Load test Storage models
    module Storage
      autoload :StorageAccount, File.expand_path('api_stub/models/storage/storageaccount', __dir__)
      autoload :File, ::File.expand_path('api_stub/models/storage/file', __dir__)
      autoload :Directory, ::File.expand_path('api_stub/models/storage/directory', __dir__)
    end

    # Load test Network models
    module Network
      autoload :PublicIp, File.expand_path('api_stub/models/network/public_ip', __dir__)
      autoload :Subnet, File.expand_path('api_stub/models/network/subnet', __dir__)
      autoload :VirtualNetwork, File.expand_path('api_stub/models/network/virtual_network', __dir__)
      autoload :NetworkInterface, File.expand_path('api_stub/models/network/network_interface', __dir__)
      autoload :LoadBalancer, File.expand_path('api_stub/models/network/load_balancer', __dir__)
      autoload :NetworkSecurityGroup, File.expand_path('api_stub/models/network/network_security_group', __dir__)
      autoload :NetworkSecurityRule, File.expand_path('api_stub/models/network/network_security_rule', __dir__)
      autoload :VirtualNetworkGateway, File.expand_path('api_stub/models/network/virtual_network_gateway', __dir__)
      autoload :VirtualNetworkGatewayConnection, File.expand_path('api_stub/models/network/virtual_network_gateway_connection', __dir__)
      autoload :ExpressRouteCircuit, File.expand_path('api_stub/models/network/express_route_circuit', __dir__)
      autoload :ExpressRouteCircuitPeering, File.expand_path('api_stub/models/network/express_route_circuit_peering', __dir__)
      autoload :ExpressRouteCircuitAuthorization, File.expand_path('api_stub/models/network/express_route_circuit_authorization', __dir__)
      autoload :ExpressRouteServiceProvider, File.expand_path('api_stub/models/network/express_route_service_provider', __dir__)
      autoload :LocalNetworkGateway, File.expand_path('api_stub/models/network/local_network_gateway', __dir__)
    end

    # Load test ApplicationGateway models
    module ApplicationGateway
      autoload :Gateway, File.expand_path('api_stub/models/application_gateway/gateway', __dir__)
    end

    # Load test TrafficManager models
    module TrafficManager
      autoload :TrafficManagerEndPoint, File.expand_path('api_stub/models/traffic_manager/traffic_manager_end_point', __dir__)
      autoload :TrafficManagerProfile, File.expand_path('api_stub/models/traffic_manager/traffic_manager_profile', __dir__)
    end

    # Load test DNS models
    module DNS
      autoload :Zone, File.expand_path('api_stub/models/dns/zone', __dir__)
      autoload :RecordSet, File.expand_path('api_stub/models/dns/record_set', __dir__)
    end

    # Load test Sql models
    module Sql
      autoload :SqlServer, File.expand_path('api_stub/models/sql/sql_server', __dir__)
      autoload :SqlDatabase, File.expand_path('api_stub/models/sql/sql_database', __dir__)
      autoload :SqlFirewallRule, File.expand_path('api_stub/models/sql/sql_firewall_rule', __dir__)
    end

    # Load test KeyVault models
    module KeyVault
      autoload :Vault, File.expand_path('api_stub/models/key_vault/vault', __dir__)
    end
  end

  module Requests
    # Load test Compute requests
    module Compute
      autoload :AvailabilitySet, File.expand_path('api_stub/requests/compute/availability_set', __dir__)
      autoload :VirtualMachine, File.expand_path('api_stub/requests/compute/virtual_machine', __dir__)
      autoload :VirtualMachineExtension, File.expand_path('api_stub/requests/compute/virtual_machine_extension', __dir__)
      autoload :ManagedDisk, File.expand_path('api_stub/requests/compute/managed_disk', __dir__)
      autoload :Image, File.expand_path('api_stub/requests/compute/image', __dir__)
      autoload :Snapshot, File.expand_path('api_stub/requests/compute/snapshot', __dir__)
    end

    # Load test Resources requests
    module Resources
      autoload :ResourceGroup, File.expand_path('api_stub/requests/resources/resource_group', __dir__)
      autoload :Deployment, File.expand_path('api_stub/requests/resources/deployment', __dir__)
      autoload :AzureResource, File.expand_path('api_stub/requests/resources/resource', __dir__)
    end

    # Load test Storage requests
    module Storage
      autoload :StorageAccount, File.expand_path('api_stub/requests/storage/storageaccount', __dir__)
      autoload :File, ::File.expand_path('api_stub/requests/storage/file', __dir__)
      autoload :Directory, ::File.expand_path('api_stub/requests/storage/directory', __dir__)
    end

    # Load test Network requests
    module Network
      autoload :PublicIp, File.expand_path('api_stub/requests/network/public_ip', __dir__)
      autoload :Subnet, File.expand_path('api_stub/requests/network/subnet', __dir__)
      autoload :VirtualNetwork, File.expand_path('api_stub/requests/network/virtual_network', __dir__)
      autoload :NetworkInterface, File.expand_path('api_stub/requests/network/network_interface', __dir__)
      autoload :LoadBalancer, File.expand_path('api_stub/requests/network/load_balancer', __dir__)
      autoload :NetworkSecurityGroup, File.expand_path('api_stub/requests/network/network_security_group', __dir__)
      autoload :NetworkSecurityRule, File.expand_path('api_stub/requests/network/network_security_rule', __dir__)
      autoload :VirtualNetworkGateway, File.expand_path('api_stub/requests/network/virtual_network_gateway', __dir__)
      autoload :VirtualNetworkGatewayConnection, File.expand_path('api_stub/requests/network/virtual_network_gateway_connection', __dir__)
      autoload :ExpressRouteCircuit, File.expand_path('api_stub/requests/network/express_route_circuit', __dir__)
      autoload :ExpressRouteCircuitPeering, File.expand_path('api_stub/requests/network/express_route_circuit_peering', __dir__)
      autoload :ExpressRouteCircuitAuthorization, File.expand_path('api_stub/requests/network/express_route_circuit_authorization', __dir__)
      autoload :ExpressRouteServiceProvider, File.expand_path('api_stub/requests/network/express_route_service_provider', __dir__)
      autoload :LocalNetworkGateway, File.expand_path('api_stub/requests/network/local_network_gateway', __dir__)
    end

    # Load test ApplicationGateway requests
    module ApplicationGateway
      autoload :Gateway, File.expand_path('api_stub/requests/application_gateway/gateway', __dir__)
    end

    # Load test TrafficManager requests
    module TrafficManager
      autoload :TrafficManagerEndPoint, File.expand_path('api_stub/requests/traffic_manager/traffic_manager_endpoint', __dir__)
      autoload :TrafficManagerProfile, File.expand_path('api_stub/requests/traffic_manager/traffic_manager_profile', __dir__)
    end

    # Load test DNS requests
    module DNS
      autoload :Zone, File.expand_path('api_stub/requests/dns/zone', __dir__)
      autoload :RecordSet, File.expand_path('api_stub/requests/dns/record_set', __dir__)
    end

    # Load test Sql requests
    module Sql
      autoload :SqlServer, File.expand_path('api_stub/requests/sql/sql_server', __dir__)
      autoload :SqlDatabase, File.expand_path('api_stub/requests/sql/database', __dir__)
      autoload :FirewallRule, File.expand_path('api_stub/requests/sql/firewall_rule', __dir__)
    end

    # Load test KeyVault requests
    module KeyVault
      autoload :Vault, File.expand_path('api_stub/requests/key_vault/vault', __dir__)
    end
  end
end

module Fog
  module Network
    class AzureRM
      # LocalNetworkGateways collection class for Network Service
      class LocalNetworkGateways < Fog::Collection
        model Fog::Network::AzureRM::LocalNetworkGateway
        attribute :resource_group

        def all
          requires :resource_group
          local_network_gateways = service.list_local_network_gateways(resource_group).map { |gateway| Fog::Network::AzureRM::LocalNetworkGateway.parse(gateway) }
          load(local_network_gateways)
        end

        def get(resource_group_name, name)
          local_network_gateway = service.get_local_network_gateway(resource_group_name, name)
          local_network_gateway_fog = Fog::Network::AzureRM::LocalNetworkGateway.new(service: service)
          local_network_gateway_fog.merge_attributes(Fog::Network::AzureRM::LocalNetworkGateway.parse(local_network_gateway))
        end
      end
    end
  end
end

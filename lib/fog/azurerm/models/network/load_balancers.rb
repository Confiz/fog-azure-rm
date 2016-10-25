module Fog
  module Network
    class AzureRM
      # LoadBalancers collection class for Network Service
      class LoadBalancers < Fog::Collection
        model LoadBalancer
        attribute :resource_group

        def all
          requires :resource_group
          load_balancers = []
          service.list_load_balancers(resource_group).each do |load_balancer|
            load_balancers << LoadBalancer.parse(load_balancer)
          end
          load(load_balancers)
        end

        def get(resource_group_name, load_balancer_name)
          lb = service.get_load_balancer(resource_group_name, load_balancer_name)
          load_balancer = LoadBalancer.new(service: service)
          load_balancer.merge_attributes(LoadBalancer.parse(lb))
        end
      end
    end
  end
end

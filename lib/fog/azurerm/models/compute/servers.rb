module Fog
  module Compute
    class AzureRM
      # This class is giving implementation of all/list, and get
      # for Server.
      class Servers < Fog::Collection
        attribute :resource_group
        model Fog::Compute::AzureRM::Server

        def all
          requires :resource_group
          virtual_machines = []
          service.list_virtual_machines(resource_group).each do |vm|
            virtual_machines << Fog::Compute::AzureRM::Server.parse(vm)
          end
          load(virtual_machines)
        end

        def create_async(attributes = {})
          server = new(attributes)
          async_response = server.save(true)
          Fog::AzureRM::AsyncResponse.new(server, async_response)
        end

        def get(resource_group_name, virtual_machine_name)
          virtual_machine = service.get_virtual_machine(resource_group_name, virtual_machine_name)
          virtual_machine_fog = Fog::Compute::AzureRM::Server.new(service: service)
          virtual_machine_fog.merge_attributes(Fog::Compute::AzureRM::Server.parse(virtual_machine))
        end

        def check_vm_exists(resource_group, name)
          service.check_vm_exists(resource_group, name)
        end
      end
    end
  end
end

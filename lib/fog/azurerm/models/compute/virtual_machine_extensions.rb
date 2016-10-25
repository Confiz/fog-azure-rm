module Fog
  module Compute
    class AzureRM
      # This class gives the implementation for get for virtual machine extension
      class VirtualMachineExtensions < Fog::Collection
        model VirtualMachineExtension
        attribute :resource_group
        attribute :vm_name

        def all
          requires :resource_group, :vm_name
          vm_extensions = []
          service.get_virtual_machine(resource_group, vm_name).resources.each do |extension|
            vm_extensions << VirtualMachineExtension.parse(extension)
          end
          load(vm_extensions)
        end

        def get(resource_group_name, virtual_machine_name, vm_extension_name)
          vm_extension = service.get_vm_extension(resource_group_name, virtual_machine_name, vm_extension_name)
          vm_extension_obj = VirtualMachineExtension.new(service: service)
          vm_extension_obj.merge_attributes(VirtualMachineExtension.parse(vm_extension))
        end
      end
    end
  end
end

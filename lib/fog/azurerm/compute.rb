module Fog
  module Compute
    # This class registers models, requests and collections
    class AzureRM < Fog::Service
      requires :tenant_id
      requires :client_id
      requires :client_secret
      requires :subscription_id
      recognizes :environment

      request_path 'fog/azurerm/requests/compute'
      request :create_availability_set
      request :delete_availability_set
      request :list_availability_sets
      request :get_availability_set
      request :check_availability_set_exists
      request :create_virtual_machine
      request :delete_virtual_machine
      request :get_virtual_machine
      request :list_virtual_machines
      request :list_available_sizes_for_virtual_machine
      request :generalize_virtual_machine
      request :deallocate_virtual_machine
      request :power_off_virtual_machine
      request :redeploy_virtual_machine
      request :restart_virtual_machine
      request :start_virtual_machine
      request :check_vm_status
      request :check_vm_exists
      request :attach_data_disk_to_vm
      request :detach_data_disk_from_vm
      request :create_or_update_vm_extension
      request :delete_vm_extension
      request :get_vm_extension
      request :check_vm_extension_exists
      request :create_or_update_managed_disk
      request :delete_managed_disk
      request :get_managed_disk
      request :check_managed_disk_exists
      request :list_managed_disks_by_rg
      request :list_managed_disks_in_subscription
      request :revoke_access_to_managed_disk
      request :grant_access_to_managed_disk
      request :create_image
      request :delete_image
      request :get_image
      request :create_or_update_snapshot
      request :list_snapshots_by_rg
      request :list_snapshots_in_subscription
      request :get_snapshot
      request :delete_snapshot

      model_path 'fog/azurerm/models/compute'
      model :availability_set
      collection :availability_sets
      model :server
      collection :servers
      model :virtual_machine_extension
      collection :virtual_machine_extensions
      model :managed_disk
      collection :managed_disks
      model :snapshot
      collection :snapshots
      model :data_disk
      model :creation_data
      model :disk_create_option
      model :encryption_settings
      model :image_disk_reference
      model :operation_status_response

      # This class provides the mock implementation for unit tests.
      class Mock
        def initialize(_options = {})
          begin
            require 'azure_mgmt_compute'
          rescue LoadError => e
            retry if require('rubygems')
            raise e.message
          end
        end
      end
      # This class provides the actual implementation for service calls.
      class Real
        def initialize(options)
          begin
            require 'azure_mgmt_compute'
            require 'azure_mgmt_storage'
            require 'azure/storage'
          rescue LoadError => e
            retry if require('rubygems')
            raise e.message
          end

          options[:environment] = 'AzureCloud' if options[:environment].nil?

          telemetry = "fog-azure-rm/#{Fog::AzureRM::VERSION}"
          credentials = Fog::Credentials::AzureRM.get_credentials(options[:tenant_id], options[:client_id], options[:client_secret], options[:environment])
          @compute_mgmt_client = ::Azure::ARM::Compute::ComputeManagementClient.new(credentials, resource_manager_endpoint_url(options[:environment]))
          @compute_mgmt_client.subscription_id = options[:subscription_id]
          @compute_mgmt_client.add_user_agent_information(telemetry)
          @storage_mgmt_client = ::Azure::ARM::Storage::StorageManagementClient.new(credentials, resource_manager_endpoint_url(options[:environment]))
          @storage_mgmt_client.subscription_id = options[:subscription_id]
          @storage_mgmt_client.add_user_agent_information(telemetry)
          @storage_service = Fog::Storage::AzureRM.new(tenant_id: options[:tenant_id], client_id: options[:client_id], client_secret: options[:client_secret], subscription_id: options[:subscription_id], environment: options[:environment])
        end
      end
    end
  end
end

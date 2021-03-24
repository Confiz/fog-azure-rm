module Fog
  module Compute
    class AzureRM
      # This class is giving implementation of create/save and
      # delete/destroy for snapshot.
      class Snapshot < Fog::Model
        attribute :id
        identity  :name
        attribute :location
        attribute :resource_group_name
        attribute :account_type
        attribute :disk_size_gb
        attribute :tags
        attribute :time_created
        attribute :creation_data
        attribute :encryption_settings
        attribute :type
        attribute :owner_id
        attribute :provisioning_state
        attribute :os_type

        def self.parse(snapshot)
          snap = get_hash_from_object(snapshot)

          snap['creation_data'] = parse_creation_data(snapshot.creation_data) unless snapshot.creation_data.nil?

          snap['encryption_settings'] = parse_encryption_settings_object(snapshot.encryption_settings) unless snapshot.encryption_settings.nil?

          snap['resource_group_name'] = get_resource_group_from_id(snapshot.id)

          snap
        end

        def destroy(async = false)
          response = service.delete_snapshot(resource_group_name, name, async)
          async ? create_fog_async_response(response) : response
        end

        def creation_data=(new_creation_data)
          attributes[:creation_data] =
            if new_creation_data.is_a?(Hash)
              creation_data = Fog::Compute::AzureRM::CreationData.new
              creation_data.merge_attributes(new_creation_data)
            else
              new_creation_data
            end
        end

        def self.parse_creation_data(azure_sdk_creation_data)
          creation_data = Fog::Compute::AzureRM::CreationData.new
          creation_data.merge_attributes(Fog::Compute::AzureRM::CreationData.parse(azure_sdk_creation_data))
        end

        def self.parse_encryption_settings_object(azure_sdk_encryption_settings)
          encryption_settings = Fog::Compute::AzureRM::EncryptionSettings.new
          encryption_settings.merge_attributes(Fog::Compute::AzureRM::EncryptionSettings.parse(azure_sdk_encryption_settings))
        end

        private_class_method :parse_creation_data, :parse_encryption_settings_object

        def save
          requires :name, :location, :resource_group_name, :creation_data
          validate_creation_data_params(creation_data)

          snapshot = service.create_or_update_snapshot(snapshot_params)
          merge_attributes(Fog::Compute::AzureRM::Snapshot.parse(snapshot))
        end

        private

        def validate_creation_data_params(creation_data)
          if !creation_data || creation_data.create_option.nil?
            raise(ArgumentError, 'creation_data.create_option is required for this operation')
          end
        end

        def snapshot_params
          {
            name: name,
            location: location,
            resource_group_name: resource_group_name,
            tags: tags,
            creation_data: creation_data.attributes,
            encryption_settings: encryption_settings
          }
        end

        def create_fog_async_response(response, delete_extra_resource = false)
          snapshot = Fog::Compute::AzureRM::Snapshot.new(service: service)
          Fog::AzureRM::AsyncResponse.new(snapshot, response, delete_extra_resource)
        end
      end
    end
  end
end

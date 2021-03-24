module Fog
  module Compute
    class AzureRM
      # Real class for Compute Request
      class Real
        def create_or_update_snapshot(snapshot_params)
          msg = "Creating/Updating snapshot: #{snapshot_params[:name]}"
          Fog::Logger.debug msg
          snapshot = get_snapshot_object(snapshot_params)
          begin
            snapshot = @compute_mgmt_client.snapshots.create_or_update(snapshot_params[:resource_group_name], snapshot_params[:name], snapshot)
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, msg)
          end
          Fog::Logger.debug "Snapshot #{snapshot_params[:name]} created/updated successfully."
          snapshot
        end

        private

        def get_snapshot_object(snapshot_params)
          snapshot = Azure::ARM::Compute::Models::Snapshot.new
          snapshot.name = snapshot_params[:name]
          snapshot.type = SNAPSHOT_PREFIX
          snapshot.location = snapshot_params[:location]
          snapshot.tags = snapshot_params[:tags] unless snapshot.tags.nil?

          creation_data = snapshot_params[:creation_data]
          snapshot.creation_data = get_creation_data_object(creation_data) unless creation_data.nil?

          encryption_settings = snapshot_params[:encryption_settings]
          snapshot.encryption_settings = get_encryption_settings_object(encryption_settings) unless encryption_settings.nil?

          snapshot
        end

        def get_creation_data_object(data)
          creation_data = Azure::ARM::Compute::Models::CreationData.new
          creation_data.create_option = data[:create_option]
          creation_data.storage_account_id = data[:storage_account_id]
          creation_data.source_uri = data[:source_uri]
          creation_data.source_resource_id = data[:source_resource_id]

          creation_data
        end

        def get_encryption_settings_object(settings)
          encryption_settings = Azure::ARM::Compute::Models::EncryptionSettings.new
          disk_encryption_key = Azure::ARM::Compute::Models::KeyVaultAndSecretReference.new
          disk_encryption_key.secret_url = settings[:secret_url]
          disk_encryption_key.source_vault.id = settings[:disk_source_vault_id]
          encryption_settings.disk_encryption_key = disk_encryption_key

          encryption_settings.enabled = settings[:enabled]

          key_encryption_key = Azure::ARM::Compute::Models::KeyVaultAndKeyReference.new
          key_encryption_key.key_url = settings[:key_uri]
          key_encryption_key.source_vault = settings[:key_source_vault_id]
          encryption_settings.key_encryption_key = key_encryption_key

          encryption_settings
        end
      end

      # Mock class for Compute Request
      class Mock
        def create_or_update_snapshot(*)
          snapshot = {
            'accountType' => 'Standard_LRS',
            'properties' => {
              'osType' => 'Windows',
              'creationData' => {
                'createOption' => 'Copy',
                'sourceUri' => '/subscriptions/{subscriptionId}/resourceGroups/myResourceGroup/providers/Microsoft.Compute/disks/myManagedDisk1'
              },
              'diskSizeGB' => 10,
              'encryptionSettings' => {
                'enabled' => true,
                'diskEncryptionKey' => {
                  'sourceVault' => {
                    'id' => '/subscriptions/{subscriptionId}/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/myVMVault'
                  },
                  'secretUrl' => 'https://myvmvault.vault-int.azure-int.net/secrets/{secret}'
                },
                'keyEncryptionKey' => {
                  'sourceVault' => {
                    'id' => '/subscriptions/{subscriptionId}/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/myVMVault'
                  },
                  'keyUrl' => 'https://myvmvault.vault-int.azure-int.net/keys/{key}'
                }
              },
              'timeCreated' => '2016-12-28T02:46:21.3322041+00:00',
              'provisioningState' => 'Succeeded',
              'diskState' => 'Unattached'
            },
            'type' => 'Microsoft.Compute/snapshots',
            'location' => 'westus',
            'tags' => {
              'department' => 'Development',
              'project' => 'Snapshots'
            },
            'id' => '/subscriptions/{subscriptionId}/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/mySnapshot1',
            'name' => 'mySnapshot'
          }
          snapshot_mapper = Azure::ARM::Compute::Models::Snapshot.mapper
          @compute_mgmt_client.deserialize(snapshot_mapper, snapshot, 'result.body')
        end
      end
    end
  end
end

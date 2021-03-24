module Fog
  module Compute
    class AzureRM
      # Real class for Compute Request
      class Real
        def get_snapshot(resource_group_name, snap_name)
          msg = "Getting Snapshot: #{snap_name}"
          Fog::Logger.debug msg
          begin
            snapshot = @compute_mgmt_client.snapshots.get(resource_group_name, snap_name)
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, msg)
          end
          Fog::Logger.debug "Snapshot #{snap_name} returned successfully."
          snapshot
        end
      end

      # Mock class for Compute Request
      class Mock
        def get_snapshot(*)
          snapshots = {
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
          @compute_mgmt_client.deserialize(snapshot_mapper, snapshots, 'result.body')
        end
      end
    end
  end
end

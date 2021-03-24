module Fog
  module Compute
    class AzureRM
      # Real class for Compute Request
      class Real
        def list_snapshots_in_subscription
          msg = 'Listing all Snapshots'
          Fog::Logger.debug msg
          begin
            snapshots = @compute_mgmt_client.snapshots.list
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, msg)
          end
          Fog::Logger.debug 'Snapshots listed successfully.'
          snapshots
        end
      end

      # Mock class for Compute Request
      class Mock
        def list_snapshots_in_subscription
          snapshots = [
            {
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
          ]
          snapshot_mapper = Azure::ARM::Compute::Models::SnapshotList.mapper
          @compute_mgmt_client.deserialize(snapshot_mapper, snapshots, 'result.body').value
        end
      end
    end
  end
end

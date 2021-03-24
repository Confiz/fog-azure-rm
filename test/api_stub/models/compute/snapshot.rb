module ApiStub
  module Models
    module Compute
      # Mock class for Snapshot Model
      class Snapshot
        def self.create_snapshot_response(sdk_compute_client)
          snap = {
            'accountType' => 'Standard_LRS',
            'properties' => {
              'osType' => 'Windows',
              'creationData' => {
                'createOption' => 'Copy',
                'sourceResourceId' => 'subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/mySnapshot'
              },
              'diskSizeGB' => 200,
              'encryptionSettings' => {
                'enabled' => true,
                'diskEncryptionKey' => {
                  'sourceVault' => {
                    'id' => '/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/myVMVault'
                  },
                  'secretUrl' => 'https://myvmvault.vault-int.azure-int.net/secrets/secret'
                },
                'keyEncryptionKey' => {
                  'sourceVault' => {
                    'id' => '/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/myVMVault'
                  },
                  'keyUrl' => 'https://myvmvault.vault-int.azure-int.net/keys/key'
                }
              },
              'timeCreated' => '2016-12-28T04:41:35.9278721+00:00',
              'provisioningState' => 'Succeeded',
              'diskState' => 'Unattached'
            },
            'type' => 'Microsoft.Compute/snapshots',
            'location' => 'westus',
            'tags' => {
              'department' => 'Development',
              'project' => 'Snapshots'
            },
            'id' => '/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/mySnapshot',
            'name' => 'mySnapshot'
          }
          result_mapper = Azure::ARM::Compute::Models::Snapshot.mapper
          sdk_compute_client.deserialize(result_mapper, snap, 'result.body')
        end
      end
    end
  end
end

module ApiStub
  module Requests
    module Compute
      # Mock class for Snapshot Requests
      class Snapshot
        def self.create_snapshot_response(sdk_compute_client)
          body = '{
                    "name": "mySnapshot2",
                    "location": "West US",
                    "properties": {
                      "creationData": {
                        "createOption": "Copy",
                        "sourceResourceId": "subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/mySnapshot1"
                      }
                    }
                  }'
          snap_mapper = Azure::ARM::Compute::Models::Snapshot.mapper
          sdk_compute_client.deserialize(snap_mapper, Fog::JSON.decode(body), 'result.body')
        end

        def self.update_snapshot_response(sdk_compute_client)
          body = '{
                    "accountType": "Standard_LRS",
                    "tags": {
                      "tagName": "tagValue"
                    },
                    "properties": {
                      "diskSizeGB": "256"
                    }
                  }'
          snap_mapper = Azure::ARM::Compute::Models::Snapshot.mapper
          sdk_compute_client.deserialize(snap_mapper, Fog::JSON.decode(body), 'result.body')
        end

        def self.get_snapshot_response(sdk_compute_client)
          body = '{"accountType": "Standard_LRS",
                   "properties": {
                     "osType": "Windows",
                     "creationData": {
                       "createOption": "Copy",
                       "sourceResourceId": "subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/mySnapshot"
                     },
                     "diskSizeGB": 200,
                     "encryptionSettings": {
                       "enabled": true,
                       "diskEncryptionKey": {
                         "sourceVault": {
                           "id": "/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/myVMVault"
                         },
                         "secretUrl": "https://myvmvault.vault-int.azure-int.net/secrets/secret"
                       },
                       "keyEncryptionKey": {
                         "sourceVault": {
                           "id": "/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/myVMVault"
                         },
                         "keyUrl": "https://myvmvault.vault-int.azure-int.net/keys/key"
                       }
                     },
                     "timeCreated": "2016-12-28T04:41:35.9278721+00:00",
                     "provisioningState": "Succeeded",
                     "diskState": "Unattached"
                   },
                   "type": "Microsoft.Compute/snapshots",
                   "location": "westus",
                   "tags": {
                     "department": "Development",
                     "project": "Snapshots"
                   },
                   "id": "/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/mySnapshot",
                   "name": "mySnapshot"}'
          snap_mapper = Azure::ARM::Compute::Models::Snapshot.mapper
          sdk_compute_client.deserialize(snap_mapper, Fog::JSON.decode(body), 'result.body')
        end

        def self.get_snapshots_response(sdk_compute_client)
          body = '{"value": [{
                      "accountType": "Standard_LRS",
                      "properties": {
                        "osType": "Windows",
                        "creationData": {
                          "createOption": "Copy",
                          "sourceResourceId": "subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/mySnapshot"
                        },
                        "diskSizeGB": 200,
                        "encryptionSettings": {
                          "enabled": true,
                          "diskEncryptionKey": {
                            "sourceVault": {
                              "id": "/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/myVMVault"
                            },
                            "secretUrl": "https://myvmvault.vault-int.azure-int.net/secrets/secret"
                          },
                          "keyEncryptionKey": {
                            "sourceVault": {
                              "id": "/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.KeyVault/vaults/myVMVault"
                            },
                            "keyUrl": "https://myvmvault.vault-int.azure-int.net/keys/key"
                          }
                        },
                        "timeCreated": "2016-12-28T04:47:30.6630569+00:00",
                        "provisioningState": "Succeeded",
                        "diskState": "Unattached"
                      },
                      "type": "Microsoft.Compute/snapshots",
                      "location": "westus",
                      "tags": {
                        "department": "Development",
                        "project": "Snapshots"
                      },
                      "id": "/subscriptions/subscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.Compute/snapshots/mySnapshot1",
                      "name": "mySnapshot1"
                    }] }'
          snap_mapper = Azure::ARM::Compute::Models::Snapshot.mapper
          sdk_compute_client.deserialize(snap_mapper, Fog::JSON.decode(body), 'result.body')
        end

        def self.operation_status_response(sdk_compute_client)
          response = {
            'name' => 'xxxx-xxxxx-xxxx',
            'status' => 'success',
            'error' => 'ERROR'
          }
          response_mapper = Azure::ARM::Compute::Models::OperationStatusResponse.mapper
          sdk_compute_client.deserialize(response_mapper, response, 'result.body')
        end
      end
    end
  end
end

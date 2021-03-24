
module Fog
  module Compute
    class AzureRM
      # Real class for Compute Request
      class Real
        def delete_snapshot(resource_group_name, snapshot_name, async = false)
          msg = "Deleting Snapshot: #{snapshot_name}"
          Fog::Logger.debug msg
          begin
            if async
              response = @compute_mgmt_client.snapshots.delete_async(resource_group_name, snapshot_name)
            else
              @compute_mgmt_client.snapshots.delete(resource_group_name, snapshot_name)
            end
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, msg)
          end
          if async
            response
          else
            Fog::Logger.debug "Snapshot #{snapshot_name} deleted successfully."
            true
          end
        end
      end

      # Mock class for Compute Request
      class Mock
        def delete_snapshot(_resource_group_name, snapshot_name)
          Fog::Logger.debug "Snapshot #{snapshot_name} deleted successfully."
          true
        end
      end
    end
  end
end

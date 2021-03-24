require File.expand_path '../../test_helper', __dir__

# Test class for List Snapshots Request
class TestListSnapshotsInSubscription < Minitest::Test
  def setup
    @service = Fog::Compute::AzureRM.new(credentials)
    @client = @service.instance_variable_get(:@compute_mgmt_client)
    @snapshots = @client.snapshots
  end

  def test_list_snapshots_in_subscription_success
    mocked_response = [ApiStub::Requests::Compute::Snapshot.create_snapshot_response(@client)]
    @snapshots.stub :list, mocked_response do
      assert_equal @service.list_snapshots_in_subscription, mocked_response
    end
  end

  def test_list_snapshots_in_subscription_failure
    response = proc { raise MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception' }) }
    @snapshots.stub :list, response do
      assert_raises(RuntimeError) { @service.list_snapshots_in_subscription }
    end
  end
end

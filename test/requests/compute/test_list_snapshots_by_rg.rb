require File.expand_path '../../test_helper', __dir__

# Test class for List Snapshots by Resource Group Request
class TestListSnapshotsByRG < Minitest::Test
  def setup
    @service = Fog::Compute::AzureRM.new(credentials)
    @client = @service.instance_variable_get(:@compute_mgmt_client)
    @snapshots = @client.snapshots
  end

  def test_list_snapshots_by_rg_success
    mocked_response = [ApiStub::Requests::Compute::Snapshot.create_snapshot_response(@client)]
    @snapshots.stub :list_by_resource_group, mocked_response do
      assert_equal @service.list_snapshots_by_rg('fog-test-rg'), mocked_response
    end
  end

  def test_list_snapshots_by_rg_failure
    response = proc { raise MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception' }) }
    @snapshots.stub :list_by_resource_group, response do
      assert_raises(RuntimeError) { @service.list_snapshots_by_rg('fog-test-rg') }
    end
  end
end

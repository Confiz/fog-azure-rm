require File.expand_path '../../test_helper', __dir__

# Test class for Get Snapshot Request
class TestGetSnapshot < Minitest::Test
  def setup
    @service = Fog::Compute::AzureRM.new(credentials)
    @client = @service.instance_variable_get(:@compute_mgmt_client)
    @snapshots = @client.snapshots
  end

  def test_get_snapshot_success
    mocked_response = ApiStub::Requests::Compute::Snapshot.get_snapshot_response(@client)
    @snapshots.stub :get, mocked_response do
      assert_equal @service.get_snapshot('myrg1', 'snapshot1'), mocked_response
    end
  end

  def test_get_snapshot_failure
    response = proc { raise MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception' }) }
    @snapshots.stub :get, response do
      assert_raises(RuntimeError) { @service.get_snapshot('myrg1', 'snapshot1') }
    end
  end
end

require File.expand_path '../../test_helper', __dir__

# Test class for Delete Snapshot Request
class TestDeleteSnapshot < Minitest::Test
  def setup
    @service = Fog::Compute::AzureRM.new(credentials)
    client = @service.instance_variable_get(:@compute_mgmt_client)
    @snapshot = client.snapshots
  end

  def test_delete_snapshot_success
    @snapshot.stub :delete, true do
      assert @service.delete_snapshot('fog-test-rg', 'test-disk')
    end
  end

  def test_delete_snapshot_failure
    response = proc { raise MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception' }) }
    @snapshot.stub :delete, response do
      assert_raises(RuntimeError) { @service.delete_snapshot('fog-test-rg', 'test-disk') }
    end
  end

  def test_delete_snapshot_async
    async_response = Concurrent::Promise.execute { 10 }
    @snapshot.stub :delete_async, async_response do
      assert_equal async_response, @service.delete_snapshot('fog-test-rg', 'test-disk', true)
    end
  end
end

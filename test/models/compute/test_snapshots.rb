require File.expand_path '../../test_helper', __dir__

# Test class for Snapshots Collection
class TestSnapshots < Minitest::Test
  def setup
    @service = Fog::Compute::AzureRM.new(credentials)
    @snapshots = Fog::Compute::AzureRM::Snapshots.new(resource_group: 'fog-test-rg', service: @service)
    @client = @service.instance_variable_get(:@compute_mgmt_client)
    @snapshot_list = [ApiStub::Models::Compute::Snapshot.create_snapshot_response(@client)]
    @snapshot = ApiStub::Models::Compute::Snapshot.create_snapshot_response(@client)
  end

  def test_collection_methods
    methods = %i(all get)
    methods.each do |method|
      assert_respond_to @snapshots, method
    end
  end

  def test_collection_attributes
    assert_respond_to @snapshots, :resource_group
  end

  def test_all_method_response
    @service.stub :list_snapshots_by_rg, @snapshot_list do
      assert_instance_of Fog::Compute::AzureRM::Snapshots, @snapshots.all
      assert @snapshots.all.size >= 1
      @snapshots.all.each do |disk|
        assert_instance_of Fog::Compute::AzureRM::Snapshot, disk
      end
    end
  end

  def test_get_method_response
    @service.stub :get_snapshot, @snapshot do
      assert_instance_of Fog::Compute::AzureRM::Snapshot, @snapshots.get('fog-test-rg', 'fog-test-snapshot')
    end
  end
end

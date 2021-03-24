require File.expand_path '../../test_helper', __dir__

# Test class for Managed Disk Model
class TestSnapshot < Minitest::Test
  def setup
    @service = Fog::Compute::AzureRM.new(credentials)
    @snapshot = snapshot(@service)
    compute_client = @service.instance_variable_get(:@compute_mgmt_client)
    @response = ApiStub::Requests::Compute::Snapshot.get_snapshot_response(compute_client)
  end

  def test_model_attributes
    attributes = %i(
      id
      name
      type
      location
      resource_group_name
      account_type
      time_created
      os_type
      disk_size_gb
      owner_id
      provisioning_state
      tags
      creation_data
      encryption_settings
      tags
    )
    attributes.each do |attribute|
      assert_respond_to @snapshot, attribute
    end
  end

  def test_model_methods
    methods = [
      :destroy
    ]
    methods.each do |method|
      assert_respond_to @snapshot, method
    end
  end

  def test_parse_method
    snap_hash = Fog::Compute::AzureRM::Snapshot.parse(@response)
    @response.instance_variables.each do |attribute|
      case attribute
      when :@creation_data
        assert_kind_of Fog::Compute::AzureRM::CreationData, snap_hash['creation_data']
      when :@encryption_settings
        assert_kind_of Fog::Compute::AzureRM::EncryptionSettings, snap_hash['encryption_settings']
      else
        assert_equal @response.instance_variable_get(attribute), snap_hash[attribute.to_s.delete('@')]
      end
    end
  end

  def test_creation_data_assign_with_objet
    snap_hash = Fog::Compute::AzureRM::Snapshot.parse(@response)
    fog_snap = Fog::Compute::AzureRM::Snapshot.new
    creation_data = snap_hash['creation_data']
    assert_kind_of Fog::Compute::AzureRM::CreationData, creation_data
    fog_snap.creation_data = creation_data
    # test assign is successsed
    assert_equal fog_snap.creation_data.source_resource_id, creation_data.source_resource_id
  end

  def test_creation_data_assign_with_hash
    snap_hash = Fog::Compute::AzureRM::Snapshot.parse(@response)
    fog_snap = Fog::Compute::AzureRM::Snapshot.new
    creation_data = snap_hash['creation_data']
    data_hash = get_hash_from_object(creation_data)['attributes']
    fog_snap.creation_data = data_hash
    # test assign is successsed
    assert_equal fog_snap.creation_data.source_resource_id, creation_data.source_resource_id
  end

  def test_destroy_method_true_response
    @service.stub :delete_snapshot, true do
      assert @snapshot.destroy
    end
  end

  def test_destroy_async_method_response
    async_response = Concurrent::Promise.execute { 10 }
    @service.stub :delete_snapshot, async_response do
      assert_instance_of Fog::AzureRM::AsyncResponse, @snapshot.destroy(async: true)
    end
  end

  def test_destroy_method_false_response
    @service.stub :delete_snapshot, false do
      assert !@snapshot.destroy
    end
  end
end

require File.expand_path '../../../test_helper', __FILE__

# Storage Container Class
class TestListContaienrs < Minitest::Test
  # This class posesses the test cases for the requests of listing storage containers.
  def setup
    @service = Fog::Storage::AzureRM.new(storage_account_credentials)
    @blob_client = @service.instance_variable_get(:@blob_client)
    @storage_container_object = ApiStub::Requests::Storage::Container.list_containers
  end

  def test_list_containers_with_service_success
    @blob_client.stub :list_containers, @storage_container_object do
      assert @service.list_containers.size >= 1
    end
  end

  def test_list_containers_with_internal_client_success
    @blob_client.stub :list_containers, @storage_container_object do
      assert @blob_client.list_containers.size >= 1
    end
  end
end

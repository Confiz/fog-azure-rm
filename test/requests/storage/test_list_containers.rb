require File.expand_path '../../test_helper', __dir__

# Storage Container Class
class TestListContainers < Minitest::Test
  # This class posesses the test cases for the requests of listing storage containers.
  def setup
    Fog.mock!
    @mock_service = Fog::Storage::AzureRM.new(storage_account_credentials)
    Fog.unmock!
    @mocked_response = mocked_storage_http_error

    @service = Fog::Storage::AzureRM.new(storage_account_credentials)
    @blob_client = @service.instance_variable_get(:@blob_client)

    @containers = ApiStub::Requests::Storage::Directory.container_list
    @containers1 = Azure::Storage::Common::Service::EnumerationResults.new
    @containers1.continuation_token = 'marker'
    @containers1.push(@containers[0])
    @containers1.push(@containers[1])
    @containers2 = Azure::Storage::Common::Service::EnumerationResults.new
    @containers2.push(@containers[2])
  end

  def test_list_containers_success
    multiple_values = lambda do |options|
      return @containers2 if options[:marker] == 'marker'
      return @containers1
    end
    @blob_client.stub :list_containers, multiple_values do
      assert_equal @containers, @service.list_containers
    end
  end

  def test_list_containers_http_exception
    http_exception = ->(*) { raise Azure::Core::Http::HTTPError.new(@mocked_response) }
    @blob_client.stub :list_containers, http_exception do
      assert_raises(Azure::Core::Http::HTTPError) do
        @service.list_containers
      end
    end
  end

  def test_list_containers_exception
    @blob_client.stub :list_containers, 'exception' do
      assert_raises(RuntimeError) do
        @service.list_containers
      end
    end
  end

  def test_list_containers_mock
    assert_equal @containers, @mock_service.list_containers
  end
end

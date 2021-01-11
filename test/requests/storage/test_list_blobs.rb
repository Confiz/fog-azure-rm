require File.expand_path '../../test_helper', __dir__

# Storage Blob Class
class TestListBlobs < Minitest::Test
  # This class posesses the test cases for the requests of listing blobs in storage containers.
  def setup
    Fog.mock!
    @mock_service = Fog::Storage::AzureRM.new(storage_account_credentials)
    Fog.unmock!
    @mocked_response = mocked_storage_http_error

    @service = Fog::Storage::AzureRM.new(storage_account_credentials)
    @blob_client = @service.instance_variable_get(:@blob_client)

    @blob_list = ApiStub::Requests::Storage::File.blob_list
    @blobs1 = Azure::Storage::Common::Service::EnumerationResults.new
    @blobs1.continuation_token = 'marker'
    @blobs1.push(@blob_list[0])
    @blobs1.push(@blob_list[1])
    @blobs2 = Azure::Storage::Common::Service::EnumerationResults.new
    @blobs2.push(@blob_list[2])
    @blobs2.push(@blob_list[3])
  end

  def test_list_blobs_success
    multiple_values = lambda do |_container_name, options|
      return @blobs2 if options[:marker] == 'marker'
      return @blobs1
    end
    @blob_client.stub :list_blobs, multiple_values do
      result = @service.list_blobs('test_container')
      assert result[:next_marker].nil?
      assert_equal @blob_list, result[:blobs]
    end
  end

  def test_list_blobs_with_max_results_success
    @blob_client.stub :list_blobs, @blobs1 do
      options = { max_results: 2 }
      result = @service.list_blobs('test_container', options)
      assert_equal 'marker', result[:next_marker]
      assert_equal @blob_list[0, 2], result[:blobs]
    end
  end

  def test_list_blobs_not_found
    exception = ->(*) { raise StandardError.new('Not found(404). Not exist') }
    @blob_client.stub :list_blobs, exception do
      assert_raises('NotFound') do
        @service.list_blobs('test_container')
      end
    end
  end

  def test_list_blobs_http_exception
    http_exception = ->(*) { raise Azure::Core::Http::HTTPError.new(@mocked_response) }
    @blob_client.stub :list_blobs, http_exception do
      assert_raises(Azure::Core::Http::HTTPError) do
        @service.list_blobs('test_container')
      end
    end
  end

  def test_list_blobs_exception
    @blob_client.stub :list_blobs, 'exception' do
      assert_raises(RuntimeError) do
        @service.list_blobs('test_container')
      end
    end
  end

  def test_list_blobs_mock
    result = @mock_service.list_blobs('test_container')
    assert_equal 'marker', result[:next_marker]
    assert_equal @blob_list, result[:blobs]
  end
end

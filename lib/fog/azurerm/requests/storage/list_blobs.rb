module Fog
  module Storage
    class AzureRM
      # This class provides the actual implementation for service calls.
      # https://msdn.microsoft.com/en-us/library/azure/dd135734.aspx
      class Real
        def list_blobs(container_name, options = {})
          options = options.dup
          options[:metadata] = true
          next_marker = nil
          blobs = []

          msg = nil

          max_results = -1
          max_results = options[:max_results].to_i if options[:max_results]
          begin
            loop do
              options[:request_id] = SecureRandom.uuid
              msg = "Listing blobs in container: #{container_name}, options: #{options}"
              Fog::Logger.debug msg
              temp = @blob_client.list_blobs(container_name, options)
              # Workaround for the issue https://github.com/Azure/azure-storage-ruby/issues/37
              raise temp unless temp.instance_of?(Azure::Storage::Common::Service::EnumerationResults)

              blobs += temp unless temp.empty?
              break if temp.continuation_token.nil? || temp.continuation_token.empty?
              options[:marker] = temp.continuation_token

              next if max_results == -1

              options[:max_results] = max_results - blobs.size
              if options[:max_results].zero?
                next_marker = temp.continuation_token
                break
              end
            end
          rescue Azure::Core::Http::HTTPError => ex
            raise 'NotFound' if ex.message.include?('(404)')
            raise_azure_exception(ex, msg)
          end

          Fog::Logger.debug "Listing blobs in container: #{container_name} successfully."
          {
            next_marker: next_marker,
            blobs: blobs
          }
        end
      end

      # This class provides the mock implementation for unit tests.
      class Mock
        def list_blobs(*)
          Fog::Logger.debug 'Listing blobs in container successfully.'
          {
            next_marker: 'marker',
            blobs: [
              {
                'name' => 'test_blob1',
                'metadata' => {},
                'properties' => {
                  'last_modified' => 'Mon, 04 Jul 2016 02:50:20 GMT',
                  'etag' => '0x8D3A3B5F017F52D',
                  'lease_status' => 'unlocked',
                  'lease_state' => 'available',
                  'content_length' => 4_194_304,
                  'content_type' => 'application/octet-stream',
                  'content_encoding' => nil,
                  'content_language' => nil,
                  'content_disposition' => nil,
                  'content_md5' => 'tXAohIyxuu/t94Lp/ujeRw==',
                  'cache_control' => nil,
                  'sequence_number' => 0,
                  'blob_type' => 'PageBlob',
                  'copy_id' => '095adc3b-e277-4c3d-97e0-0abca881f60c',
                  'copy_status' => 'success',
                  'copy_source' => 'https://testaccount.blob.core.windows.net/test_container/test_blob?snapshot=2016-02-04T08%3A35%3A50.3256874Z',
                  'copy_progress' => '4194304/4194304',
                  'copy_completion_time' => 'Thu, 04 Feb 2016 08:35:52 GMT',
                  'copy_status_description' => nil,
                  'accept_ranges' => 0
                }
              },
              {
                'name' => 'test_blob2',
                'metadata' => {},
                'properties' => {
                  'last_modified' => 'Tue, 04 Aug 2015 06:02:08 GMT',
                  'etag' => '0x8D29C92173526C8',
                  'lease_status' => 'unlocked',
                  'lease_state' => 'available',
                  'content_length' => 4_194_304,
                  'content_type' => 'application/octet-stream',
                  'content_encoding' => nil,
                  'content_language' => nil,
                  'content_disposition' => nil,
                  'content_md5' => 'tXAohIyxuu/t94Lp/ujeRw==',
                  'cache_control' => nil,
                  'sequence_number' => 0,
                  'blob_type' => 'PageBlob',
                  'copy_id' => '0abcdc3b-4c3d-e277-97e0-0abca881f60c',
                  'copy_status' => 'success',
                  'copy_source' => 'https://testaccount.blob.core.windows.net/test_container/test_blob?snapshot=2016-02-04T08%3A35%3A55.3157696Z',
                  'copy_progress' => '4194304/4194304',
                  'copy_completion_time' => 'Thu, 04 Feb 2016 08:40:52 GMT',
                  'copy_status_description' => nil,
                  'accept_ranges' => 0
                }
              },
              {
                'name' => 'test_blob3',
                'metadata' => {},
                'properties' => {
                  'last_modified' => 'Tue, 04 Aug 2015 06:02:08 GMT',
                  'etag' => '0x8D29C92173526C8',
                  'lease_status' => 'unlocked',
                  'lease_state' => 'available',
                  'content_length' => 4_194_304,
                  'content_type' => 'application/octet-stream',
                  'content_encoding' => nil,
                  'content_language' => nil,
                  'content_disposition' => nil,
                  'content_md5' => 'tXAohIyxuu/t94Lp/ujeRw==',
                  'cache_control' => nil,
                  'sequence_number' => 0,
                  'blob_type' => 'PageBlob',
                  'copy_id' => '0abcdc3b-4c3d-e277-97e0-0abca881f60c',
                  'copy_status' => 'success',
                  'copy_source' => 'https://testaccount.blob.core.windows.net/test_container/test_blob?snapshot=2016-02-04T08%3A35%3A55.3157696Z',
                  'copy_progress' => '4194304/4194304',
                  'copy_completion_time' => 'Thu, 04 Feb 2016 08:40:52 GMT',
                  'copy_status_description' => nil,
                  'accept_ranges' => 0
                }
              },
              {
                'name' => 'test_blob4',
                'metadata' => {},
                'properties' => {
                  'last_modified' => 'Tue, 04 Aug 2015 06:02:08 GMT',
                  'etag' => '0x8D29C92173526C8',
                  'lease_status' => 'unlocked',
                  'lease_state' => 'available',
                  'content_length' => 4_194_304,
                  'content_type' => 'application/octet-stream',
                  'content_encoding' => nil,
                  'content_language' => nil,
                  'content_disposition' => nil,
                  'content_md5' => 'tXAohIyxuu/t94Lp/ujeRw==',
                  'cache_control' => nil,
                  'sequence_number' => 0,
                  'blob_type' => 'PageBlob',
                  'copy_id' => '0abcdc3b-4c3d-e277-97e0-0abca881f60c',
                  'copy_status' => 'success',
                  'copy_source' => 'https://testaccount.blob.core.windows.net/test_container/test_blob?snapshot=2016-02-04T08%3A35%3A55.3157696Z',
                  'copy_progress' => '4194304/4194304',
                  'copy_completion_time' => 'Thu, 04 Feb 2016 08:40:52 GMT',
                  'copy_status_description' => nil,
                  'accept_ranges' => 0
                }
              }
            ]
          }
        end
      end
    end
  end
end

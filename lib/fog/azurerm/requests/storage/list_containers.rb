module Fog
  module Storage
    class AzureRM
      # This class provides the actual implementation for service calls.
      # https://msdn.microsoft.com/en-us/library/azure/dd179352.aspx
      class Real
        def list_containers
          options = { metadata: true }
          containers = []
          msg = nil

          begin
            loop do
              options[:request_id] = SecureRandom.uuid
              msg = "Listing containers. options: #{options}"
              Fog::Logger.debug msg
              temp = @blob_client.list_containers(options)
              # Workaround for the issue https://github.com/Azure/azure-storage-ruby/issues/37
              raise temp unless temp.instance_of?(Azure::Storage::Common::Service::EnumerationResults)

              containers += temp unless temp.empty?
              break if temp.continuation_token.nil? || temp.continuation_token.empty?
              options[:marker] = temp.continuation_token
            end
          rescue Azure::Core::Http::HTTPError => ex
            raise_azure_exception(ex, msg)
          end

          Fog::Logger.debug 'Listing containers successfully.'
          containers
        end
      end

      # This class provides the mock implementation for unit tests.
      class Mock
        def list_containers
          [
            {
              'name' => 'test_container1',
              'metadata' => {},
              'properties' => {
                'last_modified' => 'Mon, 04 Jul 2016 02:50:20 GMT',
                'etag' => '0x8D3A3B5F017F52D',
                'lease_status' => 'unlocked',
                'lease_state' => 'available'
              }
            },
            {
              'name' => 'test_container2',
              'metadata' => {},
              'properties' => {
                'last_modified' => 'Tue, 04 Aug 2015 06:01:08 GMT',
                'etag' => '0x8D29C92176C8352',
                'lease_status' => 'unlocked',
                'lease_state' => 'available'
              }
            },
            {
              'name' => 'test_container3',
              'metadata' => {},
              'properties' => {
                'last_modified' => 'Tue, 01 Sep 2015 05:15:36 GMT',
                'etag' => '0x8D2B28C5EB36458',
                'lease_status' => 'unlocked',
                'lease_state' => 'available'
              }
            }
          ]
        end
      end
    end
  end
end

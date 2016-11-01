module Fog
  module Storage
    class AzureRM
      # This class provides the actual implementation for service calls.
      class Real
        SINGLE_BLOB_PUT_THRESHOLD = 32 * 1024 * 1024
        BLOCK_SIZE = 4 * 1024 * 1024

        def upload_block_blob_from_file(container_name, blob_name, file_path, options = {})
          Fog::Logger.debug "Uploading file #{file_path} as blob #{blob_name} to the container #{container_name}."
          if file_path.nil?
            blob = @blob_client.create_block_blob container_name, blob_name, nil, options
            Fog::Logger.debug "Blob #{blob_name} created successfully."
            return blob
          end

          begin
            size = ::File.size file_path

            if size <= SINGLE_BLOB_PUT_THRESHOLD
              blob = @blob_client.create_block_blob container_name, blob_name, IO.binread(::File.expand_path(file_path)), options
            else
              blocks = []
              ::File.open file_path, 'rb' do |file|
                file_blocks = create_file_blocks(file)

                thread_blocks = divide_blocks(file_blocks)

                worker_threads = create_worker_threads(thread_blocks, container_name, blob_name, options)

                waitForThreadCompletion(worker_threads)

                file_blocks.each do |block|
                  blocks << [block[1]]
                end
              end

              @blob_client.commit_blob_blocks(container_name, blob_name, blocks, options)
              blob = get_blob_metadata(container_name, blob_name, options)
            end
          rescue IOError => ex
            raise "Exception in reading #{file_path}: #{ex.inspect}"
          rescue Azure::Core::Http::HTTPError => ex
            raise "Exception in uploading #{file_path}: #{ex.inspect}"
          end
          Fog::Logger.debug "Uploading #{file_path} successfully."
          blob
        end

        private

        def upload_file_blocks(container_name, blob_name, blocks, options)
          blocks.each do |block|
            @blob_client.put_blob_block(container_name, blob_name, block[1], block[0], options)
          end
        end

        def create_file_blocks(file)
          blocks = []
          while(read_bytes = file.read(BLOCK_SIZE))
            block_id = Base64.strict_encode64 random_string(32)
            blocks << [read_bytes, block_id]
          end
          blocks
        end

        def divide_blocks(file_blocks)
          number_of_blocks = file_blocks.length
          chunk_size = number_of_blocks / WORKER_THREAD_COUNT

          start_index = 0
          end_index = chunk_size - 1
          block_list = []

          WORKER_THREAD_COUNT.times do
            block_list << file_blocks[start_index..end_index]
            start_index = end_index + 1
            end_index += chunk_size
          end

          if start_index < file_blocks.length
            block_list << file_blocks[start_index..file_blocks.length]
          end

          if block_list.length > WORKER_THREAD_COUNT
            current_block = 0
            block_list[WORKER_THREAD_COUNT].each do |file_block|
              block_list[current_block] << file_block
              current_block += 1
            end
          end

          block_list[0, WORKER_THREAD_COUNT]
        end

        def create_worker_threads(block_list, container_name, blob_name, options)
          thread_list = []
          block_list.each do |blocks|
            thread_list << Thread.new{upload_file_blocks(container_name, blob_name, blocks, options)}
          end
          thread_list
        end

        def waitForThreadCompletion(thread_list)
          upload_completed = false
          completed_threads = 0
          until upload_completed do
            thread_list.each do |thread|
              if thread.status == false
                completed_threads += 1
              elsif thread.status.nil?
                raise 'Exception in uploading'
              end
            end

            if completed_threads == WORKER_THREAD_COUNT
              upload_completed = true
            else
              completed_threads = 0
            end
          end
        end
      end

      # This class provides the mock implementation for unit tests.
      class Mock
        def upload_block_blob_from_file(_container_name, blob_name, _file_path, _options = {})
          Fog::Logger.debug 'Blob created successfully.'
          {
            'name' => blob_name,
            'properties' =>
              {
                'last_modified' => 'Thu, 28 Jul 2016 06:53:05 GMT',
                'etag' => '0x8D3B6B3D353FFCA',
                'content_md5' => 'tXAohIyxuu/t94Lp/ujeRw=='
              }
          }
        end
      end
    end
  end
end

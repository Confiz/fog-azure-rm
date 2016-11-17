module Fog
  module Storage
    # This class registers models, requests and collections
    class AzureRM < Fog::Service
      # Recognizes when creating management client
      recognizes :tenant_id
      recognizes :client_id
      recognizes :client_secret
      recognizes :subscription_id

      # Recognizes when creating data client
      recognizes :azure_storage_account_name
      recognizes :azure_storage_access_key
      recognizes :azure_storage_connection_string
      recognizes :debug

      request_path 'fog/azurerm/requests/storage'
      # Azure Storage Account requests
      request :create_storage_account
      request :update_storage_account
      request :list_storage_accounts
      request :delete_storage_account
      request :get_storage_account
      request :list_storage_account_for_rg
      request :check_storage_account_name_availability
      request :get_storage_access_keys
      # Azure Storage Disk requests
      request :delete_disk
      request :create_disk
      # Azure Storage Container requests
      request :create_container
      request :release_container_lease
      request :acquire_container_lease
      request :delete_container
      request :list_containers
      request :put_container_metadata
      request :get_container_properties
      request :get_container_acl
      request :put_container_acl
      request :get_container_url
      # Azure Storage Blob requests
      request :list_blobs
      request :put_blob_metadata
      request :put_blob_properties
      request :get_blob_properties
      request :copy_blob
      request :copy_blob_from_uri
      request :compare_container_blobs
      request :acquire_blob_lease
      request :release_blob_lease
      request :delete_blob
      request :get_blob
      request :get_blob_url
      request :get_blob_http_url
      request :get_blob_https_url
      request :create_block_blob
      request :put_blob_block
      request :commit_blob_blocks
      request :create_page_blob
      request :put_blob_pages
      request :wait_blob_copy_operation_to_finish
      request :save_page_blob
      request :multipart_save_block_blob

      # Azure Recovery Vault requests
      request :create_or_update_recovery_vault
      request :get_recovery_vault
      request :list_recovery_vaults
      request :delete_recovery_vault
      request :enable_backup_protection
      request :set_recovery_vault_context
      request :get_backup_protection_policy
      request :start_backup
      request :get_backup_item
      request :get_backup_container
      request :disable_backup_protection
      request :get_all_backup_jobs
      request :get_all_backup_jobs
      request :get_backup_job_for_vm

      model_path 'fog/azurerm/models/storage'
      model :storage_account
      collection :storage_accounts
      model :data_disk
      model :directory
      collection :directories
      model :file
      collection :files
      model :recovery_vault
      collection :recovery_vaults

      # This class provides the mock implementation for unit tests.
      class Mock
        def initialize(_options = {})
          begin
            require 'azure_mgmt_storage'
          rescue LoadError => e
            retry if require('rubygems')
            raise e.message
          end
        end
      end

      # This class provides the actual implementation for service calls.
      class Real
        def initialize(options)
          begin
            require 'azure_mgmt_storage'
            require 'azure/storage'
            require 'securerandom'
            @debug = ENV['DEBUG'] || options[:debug]
            require 'azure/core/http/debug_filter' if @debug
          rescue LoadError => e
            retry if require('rubygems')
            raise e.message
          end

          @tenant_id = options[:tenant_id]
          @client_id = options[:client_id]
          @client_secret = options[:client_secret]
          @subscription_id = options[:subscription_id]

          credentials = Fog::Credentials::AzureRM.get_credentials(options[:tenant_id], options[:client_id], options[:client_secret])
          unless credentials.nil?
            @storage_mgmt_client = ::Azure::ARM::Storage::StorageManagementClient.new(credentials, resource_manager_endpoint_url)
            @storage_mgmt_client.subscription_id = options[:subscription_id]
          end

          return unless Fog::Credentials::AzureRM.new_account_credential?(options)

          Azure::Storage.setup(storage_account_name: options[:azure_storage_account_name],
                               storage_access_key: options[:azure_storage_access_key],
                               storage_connection_string: options[:azure_storage_connection_string])

          @blob_client = Azure::Storage::Blob::BlobService.new
          @blob_client.with_filter(Azure::Storage::Core::Filter::ExponentialRetryPolicyFilter.new)
          @blob_client.with_filter(Azure::Core::Http::DebugFilter.new) if @debug
          @signature_client = Azure::Storage::Core::Auth::SharedAccessSignature.new(options[:azure_storage_account_name],
                                                                                    options[:azure_storage_access_key])
        end
      end
    end
  end
end

# This file contains any or all custom Fog errors that we create
module Fog
  module AzureRM
    # This is a custom Fog exception inherited from MsRestAzure::AzureOperationError
    class CustomAzureOperationError < MsRestAzure::AzureOperationError
      def initialize(message, azure_exception)
        message = "Exception in #{message}"
        if azure_exception.request.nil? && azure_exception.response.nil? &&
           azure_exception.body.nil? && !azure_exception.message.nil?
          message += " #{Fog::JSON.decode(azure_exception.message)['message']}"
        end
        super(azure_exception.request, azure_exception.response, azure_exception.body, message)
      end

      def print_subscription_limits_information
        request_method = @request.method
        subscription_id = @request.path_params['subscriptionId'] unless @request.path_params.nil?

        limit_value = remaining_subscription_request_limits(@response)

        puts "Subscription: '#{subscription_id}'. Request Method: '#{request_method}'. \nLimit Value: #{limit_value['header']}: #{limit_value['value']}\n" unless limit_value.empty?
      end

      def remaining_subscription_request_limits(response)
        limit = {}
        # handles both read and write limits
        if response.headers.key? 'x-ms-ratelimit-remaining-subscription-resource-requests'
          limit['header'] = 'x-ms-ratelimit-remaining-subscription-resource-requests'
          limit['value'] = response.headers['x-ms-ratelimit-remaining-subscription-resource-requests']

        # limit for collection API calls
        elsif response.headers.key? 'x-ms-ratelimit-remaining-subscription-resource-entities-read'
          limit['header'] = 'x-ms-ratelimit-remaining-subscription-resource-entities-read'
          limit['value'] = response.headers['x-ms-ratelimit-remaining-subscription-resource-entities-read']

        # read requests limit
        elsif response.headers.key? 'x-ms-ratelimit-remaining-subscription-reads'
          limit['header'] = 'x-ms-ratelimit-remaining-subscription-reads'
          limit['value'] = response.headers['x-ms-ratelimit-remaining-subscription-reads']

        # write requests limit
        elsif response.headers.key? 'x-ms-ratelimit-remaining-subscription-writes'
          limit['header'] = 'x-ms-ratelimit-remaining-subscription-writes'
          limit['value'] = response.headers['x-ms-ratelimit-remaining-subscription-writes']
        end
        limit
      end
    end

    # This is a custom Fog exception inherited from Azure::Core::Http::HTTPError
    class CustomAzureCoreHttpError < Azure::Core::Http::HTTPError
      def initialize(azure_exception)
        super(azure_exception.http_response)
      end
    end
  end
end

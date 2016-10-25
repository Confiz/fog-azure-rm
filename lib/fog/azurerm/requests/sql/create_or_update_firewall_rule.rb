module Fog
  module Sql
    class AzureRM
      # Real class for Firewall Rule Request
      class Real
        def create_or_update_firewall_rule(firewall_hash)
          msg = "Creating SQL Firewall Rule : #{firewall_hash[:name]}."
          Fog::Logger.debug msg

          resource_url = "#{AZURE_RESOURCE}/subscriptions/#{@subscription_id}/resourceGroups/#{firewall_hash[:resource_group]}/providers/Microsoft.Sql/servers/#{firewall_hash[:server_name]}/firewallRules/#{firewall_hash[:name]}?api-version=2014-04-01-preview"
          request_parameters = get_server_firewall_parameters(firewall_hash[:start_ip], firewall_hash[:end_ip])
          begin
            token = Fog::Credentials::AzureRM.get_token(@tenant_id, @client_id, @client_secret)
            response = RestClient.put(
              resource_url,
              request_parameters.to_json,
              accept: :json,
              content_type: :json,
              authorization: token
            )
          rescue RestClient::Exception => e
            raise JSON.parse(e.response)['message']
          end
          Fog::Logger.debug "SQL Firewall Rule : #{firewall_hash[:name]} created successfully."
          JSON.parse(response)
        end

        private

        def get_server_firewall_parameters(start_ip, end_ip)
          parameters = {}
          properties = {}

          properties['startIpAddress'] = start_ip
          properties['endIpAddress'] = end_ip

          parameters['properties'] = properties

          parameters
        end
      end

      # Mock class for Sql Firewall Rule Request
      class Mock
        def create_or_update_firewall_rule(*)
          {
            'properties' => {
              'startIpAddress' => '{start-ip-address}',
              'endIpAddress' => '{end-ip-address}'
            }
          }
        end
      end
    end
  end
end

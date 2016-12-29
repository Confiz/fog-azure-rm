module Fog
  module Sql
    class AzureRM
      # Real class for Sql Firewall Rule Request
      class Real
        def delete_firewall_rule(resource_group, server_name, rule_name)
          msg = "Deleting SQL Firewall Rule: #{rule_name}."
          Fog::Logger.debug msg

          resource_url = "#{resource_manager_endpoint_url}/subscriptions/#{@subscription_id}/resourceGroups/#{resource_group}/providers/Microsoft.Sql/servers/#{server_name}/firewallRules/#{rule_name}?api-version=#{REST_CLIENT_API_VERSION[0]}"
          begin
            token = Fog::Credentials::AzureRM.get_token(@tenant_id, @client_id, @client_secret)
            RestClient.delete(
              resource_url,
              accept: :json,
              content_type: :json,
              authorization: token
            )
          rescue RestClient::Exception => e
            raise_azure_exception(e, msg)
          end
          Fog::Logger.debug "SQL Firewall Rule: #{rule_name} deleted successfully."
          true
        end
      end

      # Mock class for Sql Firewall Rule Request
      class Mock
        def delete_firewall_rule(*)
          Fog::Logger.debug 'SQL Firewall Rule {name} from SQL Server {server_name}, Resource group {resource_group} deleted successfully.'
          true
        end
      end
    end
  end
end

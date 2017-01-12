module Fog
  module DNS
    class AzureRM
      # Real class for DNS Request
      class Real
        def check_zone_exists(resource_group, name)
          msg = "Getting Zone #{name} from Resource Group #{resource_group}."
          Fog::Logger.debug msg
          begin
            zone = @dns_client.zones.get(resource_group, name)
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, msg)
          rescue => e
            Fog::Logger.debug e[:error][:code]
          end
          !zone.nil?
        end
      end

      # Mock class for DNS Request
      class Mock
        def check_zone_exists(*)
          Fog::Logger.debug 'Zone name name is available.'
          true
        end
      end
    end
  end
end

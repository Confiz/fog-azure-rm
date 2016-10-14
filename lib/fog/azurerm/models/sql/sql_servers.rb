module Fog
  module Sql
    class AzureRM
      # Sql Server Collection for Server Service
      class SqlServers < Fog::Collection
        attribute :resource_group
        model SqlServer

        def all
          requires :resource_group

          servers = []
          service.list_sql_servers(resource_group).each do |server|
            servers << SqlServer.parse(server)
          end
          load(servers)
        end

        def get(resource_group, server_name)
          server = service.get_sql_server(resource_group, server_name)
          server_obj = SqlServer.new(service: service)
          server_obj.merge_attributes(SqlServer.parse(server))
        end
      end
    end
  end
end

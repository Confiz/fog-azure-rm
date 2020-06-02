require 'ms_rest_azure'
require 'azure/core/http/http_error'
require 'erb'
require 'fog/azurerm/constants'
require 'fog/azurerm/utilities/general'
require 'fog/azurerm/version'
require 'fog/core'
require 'fog/json'

module Fog
  # Autoload Module for Credentials
  module Credentials
    autoload :AzureRM, File.expand_path('azurerm/credentials', __dir__)
  end

  # Autoload Module for Compute
  module Compute
    autoload :AzureRM, File.expand_path('azurerm/compute', __dir__)
  end

  # Autoload Module for DNS
  module DNS
    autoload :AzureRM, File.expand_path('azurerm/dns', __dir__)
  end

  # Autoload Module for Network
  module Network
    autoload :AzureRM, File.expand_path('azurerm/network', __dir__)
  end

  # Autoload Module for Resources
  module Resources
    autoload :AzureRM, File.expand_path('azurerm/resources', __dir__)
  end

  # Autoload Module for TrafficManager
  module TrafficManager
    autoload :AzureRM, File.expand_path('azurerm/traffic_manager', __dir__)
  end

  # Autoload Module for Storage
  module Storage
    autoload :AzureRM, File.expand_path('azurerm/storage', __dir__)
  end

  # Autoload Module for ApplicationGateway
  module ApplicationGateway
    autoload :AzureRM, File.expand_path('azurerm/application_gateway', __dir__)
  end

  # Autoload Module for Sql
  module Sql
    autoload :AzureRM, File.expand_path('azurerm/sql', __dir__)
  end

  # Autoload Module for KeyVault
  module KeyVault
    autoload :AzureRM, File.expand_path('azurerm/key_vault', __dir__)
  end

  # Autoload Module for Response::Asynchronous
  module AzureRM
    autoload :AsyncResponse, File.expand_path('azurerm/async_response', __dir__)
    autoload :Config, File.expand_path('azurerm/config', __dir__)
  end

  # Main AzureRM fog Provider Module
  module AzureRM
    extend Fog::Provider
    service(:resources, 'Resources')
    service(:dns, 'DNS')
    service(:storage, 'Storage')
    service(:network, 'Network')
    service(:compute, 'Compute')
    service(:application_gateway, 'ApplicationGateway')
    service(:traffic_manager, 'TrafficManager')
    service(:sql, 'Sql')
    service(:key_vault, 'KeyVault')
  end
end

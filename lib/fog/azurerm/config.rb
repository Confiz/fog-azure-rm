module AzureRM
  class Config
    def self.location
      @location || 'eastus'.freeze
    end

    def self.location=(location)
      @location = location
    end
  end
end

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/azurerm/version'

Gem::Specification.new do |spec|
  spec.name          = 'fog-azure-rm'
  spec.version       = Fog::AzureRM::VERSION
  spec.authors       = ['Shaffan Chaudhry', 'Samawia Moin', 'Adnan Khalil', 'Zeeshan Arshad', 'Haider Ali', 'Waqar Haider', 'Bilal Naeem', 'Muhammad Asad', 'Azeem Sajid', 'Maham Nazir', 'Abbas Sheikh']
  spec.summary       = "Module for the 'fog' gem to support Azure Resource Manager cloud services."
  spec.description   = "This library can be used as a module for 'fog' or as standalone provider
                        to use the Azure Resource Manager cloud services in applications.."
  spec.files = `git ls-files`.split("\n")
  spec.test_files = `git ls-files -- {spec,tests}/*`.split("\n")
  spec.require_paths = %w[lib]
  spec.license  = 'MIT'
  spec.homepage = 'https://github.com/fog/fog-azure-rm'
  spec.rdoc_options = %w[--charset=UTF-8]
  spec.extra_rdoc_files = %w[README.md]
  spec.required_ruby_version = '>= 2.0.0'
  spec.post_install_message = 'Thanks for installing!'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'minitest', '~> 5.8.4'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codeclimate-test-reporter' , '~> 1.0.0'
  spec.add_dependency 'fog-core', '~> 1.43'
  spec.add_dependency 'fog-json', '~> 1.0.2'
  spec.add_dependency 'azure_mgmt_compute', '~> 0.9.0'
  spec.add_dependency 'azure_mgmt_resources', '~> 0.9.0'
  spec.add_dependency 'azure_mgmt_storage', '~> 0.9.0'
  spec.add_dependency 'azure_mgmt_network', '~> 0.9.0'
  spec.add_dependency 'azure_mgmt_dns', '~> 0.9.0'
  spec.add_dependency 'azure_mgmt_traffic_manager', '~> 0.9.0'
  spec.add_dependency 'azure_mgmt_sql', '~> 0.9.0'
  spec.add_dependency 'azure_mgmt_key_vault', '~> 0.9.0'
  spec.add_dependency 'azure-storage', '= 0.12.2.preview'
  spec.add_dependency 'vhd', '0.0.4'
  spec.add_dependency 'mime-types', '~> 1.25'
end

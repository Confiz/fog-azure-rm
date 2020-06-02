[![Gem Version](https://badge.fury.io/rb/fog-azure-rm.svg)](https://badge.fury.io/rb/fog-azure-rm)
[![Build Status](https://travis-ci.org/fog/fog-azure-rm.svg?branch=master)](https://travis-ci.org/fog/fog-azure-rm)
[![security](https://hakiri.io/github/fog/fog-azure-rm/master.svg)](https://hakiri.io/github/fog/fog-azure-rm/master)
[![Test Coverage](https://codeclimate.com/github/fog/fog-azure-rm/badges/coverage.svg)](https://codeclimate.com/github/fog/fog-azure-rm/coverage)
[![Code Climate](https://codeclimate.com/github/fog/fog-azure-rm/badges/gpa.svg)](https://codeclimate.com/github/fog/fog-azure-rm)

# Fog Azure Resource Manager

This document describes how to get started with Fog using Microsoft Azure as a cloud resource management services provider.

## Pre-requisites

* Fog-azure-rm supports Ruby version 2.0.0 or later

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fog-azure-rm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fog-azure-rm
    
    
## Usage

You can use this gem against the Microsoft Azure Resource Manager Services in the cloud. Of course, to use the Microsoft Azure Resource Manager Services in the cloud, you need to first [create a Microsoft Azure account](http://www.azure.com/en-us/pricing/free-trial/).
* Set 'AzureRm::Config.location' based on the Azure cloud you are using in an initializer. By default it will be 'eastus'.

### Authentication

The next step to use this gem, is authentication and permissioning. It is important to get familiar with this concept. For a reference on setting up a service principal from the command line see
[Authenticating a service principal with Azure Resource Manager](http://aka.ms/cli-service-principal) or
[Unattended Authentication](http://aka.ms/auth-unattended). For a more robust explanation of authentication in Azure,
see [Developer’s guide to auth with Azure Resource Manager API](http://aka.ms/arm-auth-dev-guide).

After creating the service principal, you should have three pieces of information, a client id (GUID), client secret
(string) and tenant id (GUID).

### Compute

  Fog-AzureRM for compute includes implementation of Virtual Machines and Availability Sets. Readme for the usage of [Compute](https://github.com/fog/fog-azure-rm/blob/master/lib/fog/azurerm/docs/compute.md) module.

### Resources

  Fog-AzureRM for resources includes implementation of Resource Groups. Readme for the usage of [Resources](https://github.com/fog/fog-azure-rm/blob/master/lib/fog/azurerm/docs/resources.md) module.

### DNS

  Fog-AzureRM for dns includes implementation of Record sets and Zones. Readme for the usage of [DNS](https://github.com/fog/fog-azure-rm/blob/master/lib/fog/azurerm/docs/dns.md) module.

### Network

  Fog-AzureRM for network includes implementation of Network Interfaces, Public IPs, Subnets and Virtual Networks. Readme for the usage of [Network](https://github.com/fog/fog-azure-rm/blob/master/lib/fog/azurerm/docs/network.md) module.

### Storage

  Fog-AzureRM for storage includes implementation of Storage Accounts. Readme for the usage of [Storage](https://github.com/fog/fog-azure-rm/blob/master/lib/fog/azurerm/docs/storage.md) module.
  
### Traffic Manager
  
  Fog-AzureRM for Traffic Manager includes implementation of Traffic Manager Profile and Traffic Manager End-points. Readme for the usage of [Traffic Manager](https://github.com/fog/fog-azure-rm/blob/master/lib/fog/azurerm/docs/traffic_manager.md) module.

### SQL 
  
  Fog-AzureRM for SQL includes implementation of SQL Server, SQL Databases and Data Warehouse. Readme for the usage of [Azure SQL](https://github.com/fog/fog-azure-rm/blob/master/lib/fog/azurerm/docs/sql.md) module.

## Supported Services

Use following command for the complete list of services, Fog provides for Azure Resource Manager.

```ruby
Fog::AzureRM.services
```
# Documentation 

https://www.rubydoc.info/github/fog/fog-azure-rm/master
  
## Contributing

See [CONTRIBUTING.md](https://github.com/fog/fog-azure-rm/blob/master/CONTRIBUTING.md) in this repository.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).






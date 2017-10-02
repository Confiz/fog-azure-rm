#Resources

This document explains how to get started using Azure Resources Service with Fog. With this gem you can create/update/list/delete resource groups.

## Usage

First of all, you need to require the Fog library by executing:

```ruby
require 'fog/azurerm'
```

## Create Connection

Next, create a connection to the Resources Service:

```ruby
    azure_resources_service = Fog::Resources::AzureRM.new(
      tenant_id:        '<Tenantid>',                                                      # Tenant id of Azure Active Directory Application
      client_id:        '<Clientid>',                                                      # Client id of Azure Active Directory Application
      client_secret:    '<ClientSecret>',                                                  # Client Secret of Azure Active Directory Application
      subscription_id:  '<Subscriptionid>',                                                # Subscription id of an Azure Account
      environment:      '<AzureCloud/AzureChinaCloud/AzureUSGovernment/AzureGermanCloud>'  # Azure cloud environment. Default is AzureCloud.
)
```

## Check Resource Group Existence

```ruby
 azure_resources_service.resource_groups.check_resource_group_exists(<Resource Group name>)
```

## Create Resource Group

Create a new resource group

```ruby
    azure_resources_service.resource_groups.create(
        name:     '<Resource Group name>',
        location: '<Location>',
        tags: { key1: "value1", key2: "value2", keyN: "valueN" }                        # [Optional]
 )
```
## List Resource Groups

```ruby
    azure_resources_service.resource_groups.each do |resource_group|
        puts "#{resource_group.name}"
        puts "#{resource_group.location}"
    end
```

## Retrieve a single Resource Group

Get a single record of Resource Group

```ruby
      resource_group = azure_resources_service
                          .resource_groups
                          .get('<Resource Group name>')
      puts "#{resource_group.name}"
```

## Destroy a single Resource Group

Get resource group object from the get method(described above) and then destroy that resource group.

```ruby
      resource_group.destroy
```
## Tagging a Resource

You can tag a Resource as following:

```ruby
    azure_resources_service.tag_resource(
        '<Resource-ID>',
        '<Tag-Key>',
        '<Tag-Value>',
        '<API-Version>'
    )
```

## List Tagged Resources in a Subscription

```ruby
    azure_resources_service.azure_resources(tag_name: '<Tag-Key>', tag_value: '<Tag-Value>').each do |resource|
        puts "#{resource.name}"
        puts "#{resource.location}"
        puts "#{resource.type}"        
    end
```
OR
```ruby
    azure_resources_service.azure_resources(tag_name: '<Tag-Key>').each do |resource|
        puts "#{resource.name}"
        puts "#{resource.location}"
        puts "#{resource.type}"        
    end
```
## Retrieve a single Resource

Get a single record of Tagged Resources

```ruby
    resource = azure_resources_service
                          .azure_resources(tag_name: '<Tag-Key>')
                          .get('<Resource-ID>')
    puts "#{resource.name}"
```
## Remove tag from a Resource

Remove tag from a resource as following:

```ruby
    azure_resources_service.delete_resource_tag(
        '<Resource-ID>',
        '<Tag-Key>',
        '<Tag-Value>',
        '<API-Version>'
        )
```

## Check Resource Existence

```ruby
 azure_resources_service.azure_resources.check_azure_resource_exists(<Resource-ID>, <API-Version>)
```

## Check Deployment Existence

```ruby
 azure_resources_service.deployments.check_deployment_exists(<Resource Group Name>, <Deployment name>)
```

## Create Deployment

Create a Deployment

```ruby
    azure_resources_service.deployments.create(
        name:            '<Deployment name>',
        resource_group:  '<Resource Group name>',
        template_link:   '<Template Link>',
        parameters_link: '<Parameters Link>'
 )
```
## List Deployments

List Deployments in a resource group

```ruby
    azure_resources_service.deployments(resource_group: '<Resource Group Name>').each do |deployment|
        puts "#{deployment.name}"
    end
```

## Retrieve a single Deployment

Get a single record of Deployment

```ruby
      deployment = azure_resources_service
                          .deployments
                          .get('<Resource Group name>', '<Deployment name>')
      puts "#{deployment.name}"
```

## Destroy a single Deployment

Get Deployment object from the get method(described above) and then destroy that Deployment.

```ruby
      deployment.destroy
```

## Support and Feedback
Your feedback is appreciated! If you have specific issues with the fog ARM, you should file an issue via Github.

# Compute

This document explains how to get started using Azure Compute Service with Fog. With this gem you can create, update, list or delete availability sets and virtual machines.

## Usage

First of all, you need to require the Fog library by executing:

```ruby
require 'fog/azurerm'
```

## Create Connection

Next, create a connection to the Compute Service:

```ruby
fog_compute_service = Fog::Compute::AzureRM.new(
      tenant_id:        '<Tenant Id>',                                                             # Tenant Id of Azure Active Directory Application
      client_id:        '<Client Id>',                                                             # Client Id of Azure Active Directory Application
      client_secret:    '<Client Secret>',                                                         # Client Secret of Azure Active Directory Application
      subscription_id:  '<Subscription Id>',                                                       # Subscription Id of an Azure Account
      environment:      '<AzureCloud/AzureChinaCloud/AzureUSGovernment/AzureGermanCloud>'          # Azure cloud environment. Default is AzureCloud.
)
```

## Check Server Existence

```ruby
fog_compute_service.servers.check_vm_exists('<Resource Group Name>', '<VM Name>')
```

## Create Server

**Info:**

- Attribute **network_interface_card_ids** is an array of NICs Ids. The NIC Id at index zero will become primary NIC of this server (virtual machine) by default.
- To create VM with managed OS disk, use the _managed_disk_storage_type_ argument
- To create VM with unmanaged OS disk, use the _storage_account_name_ argument

### Virtual Machine (Managed OS Disk)

```ruby
fog_compute_service.servers.create(
        name: '<VM Name>',
        location: '<Location>',
        resource_group: '<Resource Group Name>',
	tags: { key1: 'value1', key2: 'value2', keyN: 'valueN' },
        vm_size: '<Virtual Machine Size>',
        username: '<Username>',
        disable_password_authentication: <True/False>,
        network_interface_card_ids: ['/subscriptions/<Subscription Id>/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/networkInterfaces/<Network Interface Id>'],
        publisher: '<Publisher Name>',                          # Not required if custom image is being used
        offer: '<Offer Name>',                                  # Not required if custom image is being used
        sku: '<SKU Name>',                                      # Not required if custom image is being used
        version: '<Version>',                                   # Not required if custom image is being used
        platform: '<OS Type>',
        availability_set_id: '<Availability Set Id>',           # [Optional]
        password: '<Password>',                                 # [Optional], if 'platform' partameter is 'Linux'.
        vhd_path: '<Path of VHD>',                              # [Optional], if you want to create the VM from a custom image.
        custom_data: '<Custom Data Value>',                     # [Optional], if you want to add custom data in this VM.
        os_disk_caching: '<Caching Type>',                      # [Optional], can be one of None, ReadOnly, ReadWrite
        managed_disk_storage_type: '<Storage Account Type>',    # [Optional], if storage_account_name is passed, can be StandardLRS or PremiumLRS
        os_disk_size: <Disk Size>,                              # [Optional], size of the os disk in GB (upto 1023)
        os_disk_name: '<Disk Name>'                             # [Optional], name of the os disk
)
```

**Info:**

- To create VM from Image, pass in the Image ID in `image_ref` attribute

**Limitation:**

- Image should be in the same region
- ONLY managed VM can be created from image

### Virtual Machine (Managed OS Disk from Image)

```ruby
fog_compute_service.servers.create(
        name: '<VM Name>',
        location: '<Location>',
        resource_group: '<Resource Group Name>',
	tags: { key1: 'value1', key2: 'value2', keyN: 'valueN' },
        vm_size: '<Virtual Machine Size>',
        username: '<Username>',
        disable_password_authentication: <True/False>,
        network_interface_card_ids: ['/subscriptions/<Subscription Id>/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/networkInterfaces/<Network Interface Id>'],
        publisher: '<Publisher Name>',                          # Not required if custom image is being used 
        offer: '<Offer Name>',                                  # Not required if custom image is being used
        sku: '<SKU Name>',                                      # Not required if custom image is being used
        version: '<Version>',                                   # Not required if custom image is being used
        platform: '<OS Type>',
        availability_set_id: '<Availability Set Id>',           # [Optional]
        password: '<Password>',                                 # [Optional], if 'platform' partameter is 'Linux'.
        image_ref: '<Image ID>',                                # [Optional], if you want to create the VM from a custom image.
        custom_data: '<Custom Data Value>',                     # [Optional], if you want to add custom data in this VM.
        os_disk_caching: '<Caching Type>',                      # [Optional], can be one of None, ReadOnly, ReadWrite
        managed_disk_storage_type: '<Storage Account Type>',    # [Optional], if storage_account_name is passed, can be StandardLRS or PremiumLRS
        os_disk_size: <Disk Size>,                              # [Optional], size of the os disk in GB (upto 1023)
        os_disk_name: '<Disk Name>'                             # [Optional], name of the os disk
)
```

### Virtual Machine (Unmanaged OS Disk)

```ruby
fog_compute_service.servers.create(
        name: '<VM Name>',
        location: '<Location>',
        resource_group: '<Resource Group Name>',
	tags: { key1: 'value1', key2: 'value2', keyN: 'valueN' },
        vm_size: '<Virtual Machine Size>',
        storage_account_name: '<Storage Account Name>',
        username: '<Username>',
        password: '<Password>',
        disable_password_authentication: <True/False>,
        network_interface_card_ids: ['/subscriptions/<Subscription Id>/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/networkInterfaces/<Network Interface Id>'],
        publisher: '<Publisher Name>',                    # Not required if custom image is being used
        offer: '<Offer Name>',                            # Not required if custom image is being used
        sku: '<SKU Name>',                                # Not required if custom image is being used
        version: '<Version>',                             # Not required if custom image is being used
        platform: '<OS Type>',
        availability_set_id: '<Availability Set Id>',     # [Optional]
        vhd_path: '<Path of VHD>',                        # [Optional], if you want to create the VM from a custom image.
        custom_data: '<Custom Data Value>',               # [Optional], if you want to add custom data in this VM.
        os_disk_size: <Disk Size>,                        # [Optional], size of the os disk in GB (upto 1023)
        os_disk_name: '<Disk Name>'                       # [Optional], name of the os disk
)
```

## Create Server Asynchronously

Create a new linux server asynchronously

```ruby
async_response = fog_compute_service.servers.create_async(
        name: '<VM Name>',
        location: '<Location>',
        resource_group: '<Resource Group Name>',
	tags: { key1: 'value1', key2: 'value2', keyN: 'valueN' },
        vm_size: '<Virtual Machine Size>',
        storage_account_name: '<Storage Account Name>',
        username: '<Username for VM>',
        disable_password_authentication: <True/False>,
        network_interface_card_ids: ['/subscriptions/<Subscription Id>/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/networkInterfaces/<Network Interface Id>'],
        publisher: '<Publisher Name>',                       # Not required if custom image is being used
        offer: '<Offer Name>',                               # Not required if custom image is being used
        sku: '<SKU Name>',                                   # Not required if custom image is being used
        version: '<Version>' ,                               # Not required if custom image is being used
        platform: '<OS Type>',
        availability_set_id: '<Availability Set Id>',        # [Optional]
        password: '<Password>',                              # [Optional], if 'platform' partameter is 'Linux'.
        vhd_path: '<Path of VHD>',                           # [Optional], if you want to create the VM from a custom image.
        custom_data: '<Custom Data Value>',                  # [Optional], if you want to add custom data in this VM.
        os_disk_caching: '<Caching Type>',                   # [Optional], can be one of None, ReadOnly, ReadWrite
        managed_disk_storage_type: '<Storage Account Type>', # [Optional], can be StandardLRS or PremiumLRS
        os_disk_size: <Disk Size>,                           # [Optional], size of the os disk in GB (upto 1023)
        os_disk_name: '<Disk Name>'                          # [Optional], name of the os disk
)
```
Following methods are available to handle async response:
- state
- pending?
- rejected?
- reason
- fulfilled?
- value

An example of handling async response is given below:

```ruby
while 1
    puts async_response.state

    if async_response.pending?
      sleep(2)
    end

    if async_response.fulfilled?
      puts async_response.value.inspect
      break
    end

    if async_response.rejected?
      puts async_response.reason.inspect
      break
    end
 end
```

For more information about custom_data, see link: https://msdn.microsoft.com/en-us/library/azure/mt163591.aspx

## List Servers

List servers in a resource group

```ruby
servers  = fog_compute_service.servers(resource_group: '<Resource Group Name>')
servers.each do |server|
        puts "#{server.name}"
        puts "#{server.location}"
end
```

## Retrieve a single Server

Get a single record of Server

```ruby
server = fog_compute_service
                  .servers(resource_group: '<Resource Group Name>')
                  .get('<Resource Group Name>', 'Server Name>')
puts "#{server.name}"
```

## Get a Server's status

Check the status of a Server

```ruby
status = fog_compute_service
                      .servers
                      .get('<Resource Group Name>', '<Server Name>')
                      .vm_status
puts status
```

## Start a Server
```ruby
server.start
```

## Power Off a Server
```ruby
server.power_off
```

## Restart a Server
```ruby
server.restart
```

## Deallocate a Server
```ruby
server.deallocate
```

## Redeploy a Server
```ruby
server.redeploy
```

## Destroy a single Server

Get a server object from the get method (described above) and then destroy that server.

```ruby
server.destroy
```

## Attach a Data Disk to Server

Get the server object and attach a Data Disk to it. The data disk attached is blob based.

```ruby
server.attach_data_disk('<Disk Name>', <Size in GBs>, '<Storage Account Name>')
```

## Detach a Data Disk from Server

Get the server object and detach a Data Disk from it.

```ruby
server.detach_data_disk('<Disk Name>')
```

## Create Managed Disk

Create a new Premium Managed Disk

```ruby
fog_compute_service.managed_disks.create(
        name: '<Disk Name>',
        location: '<Location>',
        resource_group_name: '<Resource Group Name>',
        account_type: '<Storage Account Type>',
        disk_size_gb: <Disk Size in GBs>,
        creation_data: {
            create_option: '<Create Option Value>'
        }
)
```

Create a new Standard Managed Disk

```ruby
fog_compute_service.managed_disks.create(
        name: '<Disk Name>',
        location: '<Location>',
        resource_group_name: '<Resource Group Name>',
        account_type: '<Storage Account Type>',
        disk_size_gb: <Disk Size in GBs>,
        creation_data: {
            create_option: '<Create Option Value>'
        }
)
```

## Attach a Managed Data Disk to Server

Get the server object and attach a Data Disk with Disk Caching Option to it. Possible <Disk Caching Option> values include: "None", "ReadOnly", "ReadWrite". By Default "None" set.

```ruby
server.attach_managed_disk('<Disk Name>', '<Disk Resource Group Name>', '<Async Option>', '<Disk Caching Option>')
```

## Detach a Managed Data Disk from Server

Get the server object and detach a Data Disk from it.

```ruby
server.detach_managed_disk('<Disk Name>')
```

## List Managed Disks in a Resource Group

List managed disks in a resource group

```ruby
managed_disks  = fog_compute_service.managed_disks(resource_group: '<Resource Group Name>')
managed_disks.each do |disk|
      puts "#{disk.name}"
      puts "#{disk.location}"
end
```

## List Managed Disks in a Subscription

List managed disks in a subscription

```ruby
fog_compute_service.managed_disks.each do |disk|
     puts "#{disk.name}"
     puts "#{disk.location}"
end
```

## Grant Access to a Managed Disk

Grant access to a managed disk

```ruby
access_sas = fog_compute_service.managed_disks.grant_access('<Resource Group Name>', '<Disk Name>', '<Access Type>', <Duration in Seconds>)
puts "Access SAS: #{access_sas}"
```

## Revoke Access from a Managed Disk

Revoke access from a managed disk

```ruby
response = fog_compute_service.managed_disks.revoke_access('<Resource Group Name>', '<Disk Name>')
puts "Revoke Access response status: #{response.status}"
```

## Check Managed Disk Existence

```ruby
fog_compute_service.managed_disks.check_managed_disk_exists('<Resource Group Name>', '<Disk Name>')
```

## Retrieve a single Managed Disk

Get a single record of managed disks

```ruby
managed_disk = fog_compute_service
                       .managed_disks
                       .get('<Resource Group Name>', '<Disk Name>')
puts "#{managed_disk.name}"
```

## Destroy a single Managed Disk

Get an managed disk object from the get method and then destroy that managed disk.

```ruby
managed_disk.destroy
# Can be made asynchronously (is synchronous by default)
managed_disk.destroy(true)
```

## List Snapshots in a Resource Group

List Snapshots in a Resource Group

```ruby
snapshots = fog_compute_service.snapshots(resource_group: '<Resource Group Name>')
snapshots.each do |snap|
      puts "#{snap.name}"
      puts "#{snap.location}"
end
```

## List Snapshots in a Subscription

List Snapshots in a subscription

```ruby
snapshots = fog_compute_service.snapshots
snapshots.each do |snap|
      puts "#{snap.name}"
      puts "#{snap.location}
end
```

## Get one Snapshot in a Resource Group

get one Snapshot in a Resource Group

```ruby
snap = fog_compute_service.snapshots.get('<Resource Group Name>', 'snapshot-name')
puts "#{snap.name}"
puts "#{snap.location}
```

## Destroy a Snapshot
Destroy a Snapshot

```ruby
snapshot.destroy
```

## Check Availability Set Existence

```ruby
fog_compute_service.availability_sets.check_availability_set_exists('<Resource Group Name>', '<Availability Set Name>')
```

## Create Availability Set

Create a new availability set

```ruby
fog_compute_service.availability_sets.create(
    name: '<Availability Set Name>',
    location: '<Location>',
    resource_group: '<Resource Group Name>'
    platform_fault_domain_count: <No of Fault Domains>,     # [Optional] Default => 2
    platform_update_domain_count: <No of Update Domains>,   # [Optional] Default => 5
    use_managed_disk: true                                  # [Optional] Possible values true or false
)
```
## List Availability Sets

List availability sets in a resource group

```ruby
availability_sets  = fog_compute_service.availability_sets(resource_group: '<Resource Group Name>')
availability_sets.each do |availability_set|
     puts "#{availability_set.name}"
     puts "#{availability_set.location}"
end
```

## Retrieve a single Availability Set

Get a single record of Availability Set

```ruby
availability_set = fog_compute_service
                        .availability_sets
                        .get('<Resource Group Name>','<Availability Set Name>')
puts "#{availability_set.name}"
```

## Destroy a single Availability Set

Get an availability set object from the get method and then destroy that availability set.

```ruby
availability_set.destroy
```

## Check Virtual Machine Extension Existence

```ruby
fog_compute_service.virtual_machine_extensions.check_vm_extension_exists('<Resource Group Name>', '<Virtual Machine Name>', '<Extension Name>')
```

## Create Virtual Machine Extension

Installs an extension to the specified virtual machine.

```ruby
fog_compute_service.virtual_machine_extensions.create(
        name: '<Extension Name>',
        resource_group: '<Resource Group Name>',
        location: '<Location>',
        vm_name: '<Virtual Machine Name>',            # Extension will be installed on this VM
        publisher: '<Extension Publisher>',
        type: '<Extension Type>',
        type_handler_version: '<Extension Version>',
        settings: {JSON object},                      # Format: {"key": "value", "key": {"key": "value"}}
        protected_settings: {JSON object},
        auto_upgrade_minor_version: <True/False> ,   # Optional
)
```

## Get Extension from Virtual Machine

Retrieves the given extension from the virtual machine

```ruby
vm_extension = fog_compute_service.virtual_machine_extensions.get(
        '<Resource Group Name>', '<Virtual Machine Name>', '<Extension Name>'
)
```

## Update Extension

Update the given extension. The attributes that can be modified are
- auto_upgrade_minor_version
- settings
- protected_settings

```ruby
vm_extension.update(
        auto_upgrade_minor_version: <True/False>,
        settings: {JSON object},
        protected_settings: {JSON object}
)
```

## Destroy Extension

Destroy the given extension from the virtual machine

```ruby
vm_extension.destroy
```

## Support and Feedback
Your feedback is appreciated! If you have specific issues with the fog ARM, you should file an issue via Github.

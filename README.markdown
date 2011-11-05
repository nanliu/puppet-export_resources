# Puppet export_resources
## Overview

The goal of this module is to simplify export resource usage and testing. Unlike puppet built in export resource (@@type), this does not require stored_config and allows export of resource on a per attribute level.

Limitations of puppet builtin export resources(@@type):

* require storeconfig database
* can not export resources attribute (only complete resource).
* no support for isolation between environments

This modules overcome these limitations:

* store export data in yaml (collect via import_resources->create_resources).
* export resources or resource  attributes and merge attribute resources on merge:
     export_resources(/data/resource_type, title, params)
     export_resources(/data/resource_type/attribute, member, params)
* provide isolate environments for export and import:
    export(/data/${environment}/resource_type, title, params)

This also provides graceful failure. Import failures will generate both puppet master compilation warnings, as well as notify messages for teh puppet agent.

## Usage

      export_resources('/file/path', title, params)

This will create /file/path/title with the listed params in yaml. export resource will only update the file when necessary and it will write the following information for troubleshooting purpose:

     # export_resources system: #{export system certname} config: #{puppet config_version}"

An example would be:

     # export_resources system: raiden.local config: 1320132475
     --- 
       state: STATE_ENABLED

import_resources('/file/path/title')

This will not only import the yaml file but also sub directories. Resource in subdirectories are expected to be concatenated (Hash merge, Array <<, String +=).

     /tmp/f5_pool
                 ├── app_1
                 │   └── member
                 │       ├── server1.yaml
                 │       └── server2.yaml
                 └── app_1.yaml

The example above will be imported via import_resources('/tmp/f5_pool/', 'app_1'). The following data will be merged into the final resoure hash:

    # /tmp/f5_pool/app_1.yaml
    --- 
       state: STATE_ENABLED
    # /tmp/f5_pool/app_1/member/server1.yaml
    --- 
      10.0.0.1:80: 
        priority: "2"
        minimum: "1"
    # /tmp/f5_pool/app_1/member/server2.yaml
    --- 
      10.0.0.2:80: 
        priority: "0"
        minimum: "1"

    # import_resource result hash which is suitable for create_resource.
    { "app_1" => { "member" => { "10.0.0.2:80" => {"priority"=>"0", "minimum"=>"1"},
                                 "10.0.0.1:80" => {"priority"=>"2", "minimum"=>"1"}
                               },
                   "state"=>"STATE_ENABLED"}
    }

The import_resources function is designed to skipped failed resources gracefully and provide compilation warnings and an notify message for the agent, so both the puppet master and agent get viable error messages:

    warning: Failed to load resource values: can't convert String into Hash, skipping server3.yaml in /tmp/f5_pool/app_1 ...
    notice: Scope(Class[main]): {"app_1"=>{"member"=>{"10.0.0.2:80"=>{"priority"=>"0", "minimum"=>"1"}, "10.0.0.1:80"=>{"priority"=>"2", "minimum"=>"1"}}, "state"=>"STATE_ENABLED"}}
    notice: Failed to load resource attribute: can't convert String into Hash, skipping server3.yaml in /tmp/f5_pool/app_1 ...
    notice: /Stage[main]//Notify[server3.yaml]/message: defined 'message' as 'Failed to load resource attribute: can't convert String into Hash, skipping server3.yaml ...'
    notice: Finished catalog run in 0.04 seconds

# Puppet export_resource
## Overview

The goal of this module is to simplify export resource usage and testing. Unlike puppet built in export resource (@@type), this does not require stored_config and allows export of resource on a per attribute level.

## Usage

export_resource('/file/path', title, params)

This will create /file/path/title with the listed params in yaml. export resource will only update the file when necessary and it will write the following information for troubleshooting purpose:

     # export_resource system: #{export system certname} config: #{puppet config_version}"

An example would be:

     # export_resource system: raiden.local config: 1320132475
     --- 
       state: STATE_ENABLED

import_resource('/file/path/title')

This will not only import the yaml file but also sub directories. Resource in subdirectories are expected to be concatenated (Hash merge, Array <<, String +=).

     /tmp/f5_pool
                 ├── app_1
                 │   └── member
                 │       ├── server1.yaml
                 │       └── server2.yaml
                 └── app_1.yaml

The example above will be imported via import_resource('/tmp/f5_pool/app_1'). The following data will be merged into the final resoure hash:

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

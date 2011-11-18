$app = 'app_1'

$pool= { 'state' => 'STATE_ENABLED',
       }

export_resources('/tmp/f5_pool', $app , $pool)

$server1 = { '10.0.0.1:80' => {
                                priority => 2,
                                minimum  => 1,
                              }
           }

$server2 = { '10.0.0.2:80' => {
                                priority => 0,
                                minimum  => 1,
                              }
           }

export_resources("/tmp/f5_pool/${app}/member", 'server1', $server1)
export_resources("/tmp/f5_pool/${app}/member", 'server2', $server2)

USING: accessors destructors io.pools kernel locals sequences tools.test ;
IN: io.pools.tests

TUPLE: test-connection < disposable ;
M: test-connection dispose* drop ;
TUPLE: test-pool < pool ;
M: test-pool make-connection drop test-connection new-disposable ;

! A burst retains only the configured number of idle connections.
{ 1 f t } [
    test-pool <pool> 1 >>max-idle [| pool |
        pool acquire-connection :> first
        pool acquire-connection :> second
        first pool return-connection
        second pool return-connection
        pool connections>> length first disposed>> second disposed>>
    ] with-disposal
] unit-test

! Zero retention still allows acquisition without an infinite retry loop.
{ t t } [
    test-pool <pool> 0 >>max-idle [| pool |
        pool acquire-connection :> conn
        conn pool return-connection
        conn disposed>> pool connections>> empty?
    ] with-disposal
] unit-test

! A connection checked out during pool disposal must still be closed.
{ t } [
    test-pool <pool> [| pool |
        pool acquire-connection :> conn
        pool dispose
        conn pool return-connection
        conn disposed>>
    ] call
] unit-test

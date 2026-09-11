IN: db.pools.tests
USING: db.pools tools.test continuations io.files io.files.temp
io.directories io.pools namespaces accessors kernel locals math
destructors sequences ;

{ 1 0 } [ [ ] with-db-pool ] must-infer-as

{ 1 0 } [ [ ] with-db-pooled-connection ] must-infer-as

! Test behavior after image save/load
USE: db.sqlite

"pool-test.db" temp-file ?delete-file

{ } [ "pool-test.db" temp-file <sqlite-db> <db-pool> "pool" set ] unit-test

{ } [ "pool" get expired>> t >>expired drop ] unit-test

{ } [ 1000 [ "pool" get [ ] with-db-pooled-connection ] times ] unit-test

{ } [ "pool" get dispose ] unit-test

! Returning a burst closes excess native database connections.
{ 16 24 } [
    "pool-test.db" temp-file <sqlite-db> <db-pool> [| pool |
        40 [ pool acquire-connection ] replicate :> connections
        connections [ pool return-connection ] each
        pool connections>> length
        connections [ disposed>> ] count
    ] with-disposal
] unit-test

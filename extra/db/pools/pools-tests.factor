IN: db.pools.tests
USING: db.pools tools.test continuations io.files namespaces
accessors kernel math destructors ;

\ <db-pool> must-infer

{ 2 0 } [ [ ] with-db-pool ] must-infer-as

{ 1 0 } [ [ ] with-pooled-db ] must-infer-as

! Test behavior after image save/load
USE: db.sqlite

[ "pool-test.db" temp-file delete-file ] ignore-errors

[ ] [ "pool-test.db" sqlite-db <db-pool> "pool" set ] unit-test

[ ] [ "pool" get expired>> t >>expired drop ] unit-test

[ ] [ 1000 [ "pool" get [ ] with-pooled-db ] times ] unit-test

[ ] [ "pool" get dispose ] unit-test

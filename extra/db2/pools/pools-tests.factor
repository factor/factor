USING: accessors continuations db2.pools db2.sqlite
db2.sqlite.connections destructors io.directories io.files
io.files.temp kernel math namespaces tools.test
db2.sqlite.connections ;
IN: db2.pools.tests

\ <db-pool> must-infer

{ 1 0 } [ [ ] with-db-pool ] must-infer-as

{ 1 0 } [ [ ] with-pooled-db ] must-infer-as

! Test behavior after image save/load

[ "pool-test.db" temp-file delete-file ] ignore-errors

[ ] [ "pool-test.db" temp-file <sqlite-db> <db-pool> "pool" set ] unit-test

[ ] [ "pool" get expired>> t >>expired drop ] unit-test

[ ] [ 1000 [ "pool" get [ ] with-pooled-db ] times ] unit-test

[ ] [ "pool" get dispose ] unit-test

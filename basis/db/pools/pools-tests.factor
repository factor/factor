IN: db.pools.tests
USING: db.pools tools.test continuations io.files io.files.temp
io.directories namespaces accessors kernel math destructors ;

{ 1 0 } [ [ ] with-db-pool ] must-infer-as

{ 1 0 } [ [ ] with-pooled-db ] must-infer-as

! Test behavior after image save/load
USE: db.sqlite

"pool-test.db" temp-file ?delete-file

{ } [ "pool-test.db" temp-file <sqlite3-db> <db-pool> "pool" set ] unit-test

{ } [ "pool" get expired>> t >>expired drop ] unit-test

{ } [ 1000 [ "pool" get [ ] with-pooled-db ] times ] unit-test

{ } [ "pool" get dispose ] unit-test

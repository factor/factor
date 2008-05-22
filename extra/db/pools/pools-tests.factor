IN: db.pools.tests
USING: db.pools tools.test ;

\ <db-pool> must-infer

{ 2 0 } [ [ ] with-db-pool ] must-infer-as

{ 1 0 } [ [ ] with-pooled-db ] must-infer-as

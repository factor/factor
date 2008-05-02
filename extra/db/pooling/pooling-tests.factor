IN: db.pooling.tests
USING: db.pooling tools.test ;

\ <pool> must-infer

{ 2 0 } [ [ ] with-db-pool ] must-infer-as

{ 1 0 } [ [ ] with-pooled-connection ] must-infer-as

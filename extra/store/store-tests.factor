USING: assocs continuations debugger io.files kernel
namespaces store tools.test ;
IN: temporary

SYMBOL: store
SYMBOL: foo
SYMBOL: bar


: the-store ( -- path )
    "store-test.store" resource-path ;

: delete-the-store ( -- )
    [ the-store delete-file ] catch drop ;

: load-the-store ( -- )
    the-store load-store store set ;

: save-the-store ( -- )
    store get save-store ;

delete-the-store
the-store load-store store set

[ f ] [ foo store get store-data at ] unit-test

[ ] [ 100 foo store get store-variable ] unit-test

[ ] [ save-the-store ] unit-test

[ 100 ] [ foo store get store-data at ] unit-test

1000 foo set

[ ] [ save-the-store ] unit-test

[ ] [ load-the-store ] unit-test

[ 1000 ] [ foo store get store-data at ] unit-test

delete-the-store

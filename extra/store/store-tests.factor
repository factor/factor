USING: assocs continuations debugger io.files kernel
namespaces store tools.test ;
IN: temporary

SYMBOL: store
SYMBOL: foo

: the-store ( -- path )
    "store-test.store" resource-path ;

: delete-the-store ( -- )
    [ the-store delete-file ] catch drop ;

: load-the-store ( -- )
    the-store load-store store set-global ;

: save-the-store ( -- )
    store save-store ;

delete-the-store
load-the-store

[ f ] [ foo store get-persistent ] unit-test

USE: prettyprint
store get-global store-data .

[ ] [ 100 foo store set-persistent ] unit-test

[ ] [ save-the-store ] unit-test

[ 100 ] [ foo store get-persistent ] unit-test

delete-the-store
f store set-global

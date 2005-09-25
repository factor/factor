USING: compiler hashtables kernel math namespaces sequences test ;

: store-hash ( hashtable n -- )
    [ dup pick set-hash ] each drop ;

: lookup-hash ( hashtable n -- )
    [ over hash drop ] each drop ;

: hashtable-benchmark ( -- )
    100 [
        drop
        80000 100000 <hashtable> swap 2dup store-hash lookup-hash
    ] each ; compiled

[ ] [ hashtable-benchmark ] unit-test

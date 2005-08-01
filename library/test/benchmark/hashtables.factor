USING: compiler hashtables kernel math namespaces sequences test ;

: store-hash ( hashtable n -- )
    [ >float dup pick set-hash ] each drop ;

: lookup-hash ( hashtable n -- )
    [ >float over hash drop ] each drop ;

: hashtable-benchmark ( -- )
    100 [
        80000 1000 <hashtable> swap 2dup store-hash lookup-hash
    ] times ; compiled

[ ] [ hashtable-benchmark ] unit-test

USING: compiler hashtables kernel math namespaces test ;

: store-hash ( hashtable n -- )
    [ [ >float dup pick set-hash ] keep ] repeat drop ;

: lookup-hash ( hashtable n -- )
    [ [ >float over hash drop ] keep ] repeat drop ;

: hashtable-benchmark ( -- )
    100 [
        80000 1000 <hashtable> swap 2dup store-hash lookup-hash
    ] times ; compiled

[ ] [ hashtable-benchmark ] unit-test

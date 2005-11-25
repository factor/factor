IN: temporary
USING: compiler hashtables kernel math memory namespaces
sequences strings test ;

: store-hash ( hashtable seq -- )
    [ dup pick set-hash ] each drop ;

: lookup-hash ( hashtable seq -- )
    [ over hash drop ] each drop ;

: hashtable-benchmark ( seq -- )
    100 [
        drop
        100000 <hashtable> swap 2dup store-hash lookup-hash
    ] each-with ; compiled

[ ] [ [ string? ] instances hashtable-benchmark ] unit-test

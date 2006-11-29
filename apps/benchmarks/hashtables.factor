IN: temporary
USING: compiler hashtables kernel math memory namespaces
sequences strings test ;

: hash-bench-step ( hash elt -- )
    3 random-int {
        { [ dup 0 = ] [ drop dup rot set-hash ] }
        { [ dup 1 = ] [ drop swap remove-hash ] }
        { [ dup 2 = ] [ drop swap hash drop ] }
    } cond ;

: hashtable-benchmark ( seq -- )
    10000 <hashtable> swap 10 [
        drop
        [
            [
                hash-bench-step
            ] each-with
        ] 2keep
    ] each 2drop ;

[ ] [ [ string? ] instances hashtable-benchmark ] unit-test

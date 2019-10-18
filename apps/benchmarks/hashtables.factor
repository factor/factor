IN: temporary
USING: compiler hashtables kernel math memory namespaces
sequences strings test assocs ;

: hash-bench-step ( hash elt -- )
    3 random {
        { 0 [ dup rot set-at ] }
        { 1 [ swap delete-at ] }
        { 2 [ swap at drop ] }
    } case ;

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

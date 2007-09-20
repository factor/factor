USING: tools.test hash2 kernel ;

: sample-hash
    5 <hash2>
    dup 2 3 "foo" roll set-hash2
    dup 4 2 "bar" roll set-hash2
    dup 4 7 "other" roll set-hash2 ;

[ "foo" ] [ 2 3 sample-hash hash2 ] unit-test
[ "bar" ] [ 4 2 sample-hash hash2 ] unit-test
[ "other" ] [ 4 7 sample-hash hash2 ] unit-test
[ f ] [ 4 12 sample-hash hash2 ] unit-test
[ f ] [ 1 1 sample-hash hash2 ] unit-test

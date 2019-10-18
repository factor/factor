IN: temporary
USING: compiler kernel math math-internals sequences test ;

: empty-loop-0 ( n -- )
    dup 0 fixnum< [ drop ] [ 1 fixnum-fast empty-loop-0 ] if ;
    compiled

: empty-loop-1 ( n -- )
    [ ] times ; compiled

: empty-loop-2 ( n -- )
    [ ] repeat ; compiled

: empty-loop-3 ( n -- )
    [ drop ] each ; compiled

[ ] [ 5000000 empty-loop-0 ] unit-test
[ ] [ 5000000 empty-loop-1 ] unit-test
[ ] [ 5000000 empty-loop-2 ] unit-test
[ ] [ 5000000 empty-loop-3 ] unit-test

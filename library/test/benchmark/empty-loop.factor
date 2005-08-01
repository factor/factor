IN: temporary
USING: compiler kernel math sequences test ;

: empty-loop-1 ( n -- )
    [ ] times ; compiled

: empty-loop-2 ( n -- )
    [ ] repeat ; compiled

: empty-loop-3 ( n -- )
    [ drop ] each ; compiled

[ ] [ 5000000 empty-loop-1 ] unit-test
[ ] [ 5000000 empty-loop-2 ] unit-test
[ ] [ 5000000 empty-loop-3 ] unit-test

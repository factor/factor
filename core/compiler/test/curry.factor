USING: tools.test compiler quotations math kernel sequences
assocs namespaces ;
IN: temporary

[ 3 ] [ 5 [ [ 2 - ] curry call ] compile-1 ] unit-test
[ 3 ] [ [ 5 [ 2 - ] curry call ] compile-1 ] unit-test
[ 3 ] [ [ 5 2 [ - ] 2curry call ] compile-1 ] unit-test
[ 3 ] [ 5 [ 2 [ - ] 2curry call ] compile-1 ] unit-test
[ 3 ] [ 5 2 [ [ - ] 2curry call ] compile-1 ] unit-test
[ 3 ] [ 5 2 [ [ - ] 2curry 9 swap call /i ] compile-1 ] unit-test
[ 3 ] [ 5 2 [ [ - ] 2curry >r 9 r> call /i ] compile-1 ] unit-test

[ -10 -20 ] [ 10 20 -1 [ [ * ] curry 2apply ] compile-1 ] unit-test

[ [ 5 2 - ] ] [ 5 [ [ 2 - ] curry ] compile-1 >quotation ] unit-test
[ [ 5 2 - ] ] [ [ 5 [ 2 - ] curry ] compile-1 >quotation ] unit-test
[ [ 5 2 - ] ] [ [ 5 2 [ - ] 2curry ] compile-1 >quotation ] unit-test
[ [ 5 2 - ] ] [ 5 [ 2 [ - ] 2curry ] compile-1 >quotation ] unit-test
[ [ 5 2 - ] ] [ 5 2 [ [ - ] 2curry ] compile-1 >quotation ] unit-test

[ [ 6 2 + ] ]
[
    2 5
    [ >r [ + ] curry r> 0 < [ -2 ] [ 6 ] if swap curry ]
    compile-1 >quotation
] unit-test

[ 8 ]
[
    2 5
    [ >r [ + ] curry r> 0 < [ -2 ] [ 6 ] if swap curry call ]
    compile-1
] unit-test

: foobar ( quot -- )
    dup slip swap [ foobar ] [ drop ] if ; inline

[ ] [ [ [ f ] foobar ] compile-1 ] unit-test

[ { 6 7 8 } ] [ { 1 2 3 } 5 [ [ + ] curry map ] compile-1 ] unit-test
[ { 6 7 8 } ] [ { 1 2 3 } [ 5 [ + ] curry map ] compile-1 ] unit-test

: funky-assoc>map
    [
        [ call f ] curry assoc-find 3drop
    ] { } make ; inline

[ t ] [
    global [ [ drop , ] funky-assoc>map ] compile-1
    global keys =
] unit-test

[ 3 ] [ 1 [ 2 ] [ curry [ 3 ] [ 4 ] if ] compile-1 ] unit-test

[ 3 ] [ t [ 3 [ ] curry 4 [ ] curry if ] compile-1 ] unit-test

[ 3 ] [ t [ 3 [ ] curry [ 4 ] if ] compile-1 ] unit-test

[ 4 ] [ f [ 3 [ ] curry 4 [ ] curry if ] compile-1 ] unit-test

[ 4 ] [ f [ [ 3 ] 4 [ ] curry if ] compile-1 ] unit-test

USING: inverse tools.test arrays math kernel sequences
math.functions ;
IN: inverse-tests

[ 2 ] [ { 3 2 } [ 3 swap 2array ] undo ] unit-test
[ { 3 4 } [ dup 2array ] undo ] unit-test-fails

TUPLE: foo bar baz ;

C: <foo> foo

[ 1 2 ] [ 1 2 <foo> [ <foo> ] undo ] unit-test

: 2same ( x -- {x,x} ) dup 2array ;

[ t ] [ { 3 3 } [ 2same ] matches? ] unit-test
[ f ] [ { 3 4 } [ 2same ] matches? ] unit-test
[ [ 2same ] matches? ] unit-test-fails

: something ( array -- num )
    {
        { [ dup 1+ 2array ] [ 3 * ] }
        { [ 3array ] [ + + ] }
    } switch ;

[ 5 ] [ { 1 2 2 } something ] unit-test
[ 6 ] [ { 2 3 } something ] unit-test
[ { 1 } something ] unit-test-fails

[ 1 2 [ eq? ] undo ] unit-test-fails

: f>c ( *fahrenheit -- *celsius )
    32 - 1.8 / ;

[ { 212 32 } ] [ { 100 0 } [ [ f>c ] map ] undo ] unit-test
[ { t t f } ] [ { t f 1 } [ [ >boolean ] matches? ] map ] unit-test
[ { t f } ] [ { { 1 2 3 } 4 } [ [ >array ] matches? ] map ] unit-test
[ 9 9 ] [ 3 [ 1/2 ^ ] undo 3 [ sqrt ] undo ] unit-test
[ 5 ] [ 6 5 - [ 6 swap - ] undo ] unit-test
[ 6 ] [ 6 5 - [ 5 - ] undo ] unit-test

TUPLE: cons car cdr ;

C: <cons> cons

TUPLE: nil ;

C: <nil> nil

: list-sum ( list -- sum )
    {
        { [ <cons> ] [ list-sum + ] }
        { [ <nil> ] [ 0 ] }
        { [ ] [ "Malformed list" throw ] }
    } switch ;

[ 10 ] [ 1 2 3 4 <nil> <cons> <cons> <cons> <cons> list-sum ] unit-test
[ ] [ <nil> [ <nil> ] undo ] unit-test
[ 1 2 ] [ 1 2 <cons> [ <cons> ] undo ] unit-test
[ t ] [ 1 2 <cons> [ <cons> ] matches? ] unit-test
[ f ] [ 1 2 <cons> [ <foo> ] matches? ] unit-test

: empty-cons ( -- cons ) cons construct-empty ;
: cons* ( cdr car -- cons ) { set-cons-cdr set-cons-car } cons construct ;

[ ] [ T{ cons f f f } [ empty-cons ] undo ] unit-test
[ 1 2 ] [ 2 1 <cons> [ cons* ] undo ] unit-test

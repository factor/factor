USING: tools.test hash2 kernel ;
IN: hash2.tests

[ t ] [ 1 2 { 1 2 } 2= ] unit-test
[ f ] [ 1 3 { 1 2 } 2= ] unit-test

: sample-hash ( -- hash )
    5 <hash2>
    [ [ 2 3 "foo" ] dip set-hash2 ] keep
    [ [ 4 2 "bar" ] dip set-hash2 ] keep
    [ [ 4 7 "other" ] dip set-hash2 ] keep ;

[ "foo" ] [ 2 3 sample-hash hash2 ] unit-test
[ "bar" ] [ 4 2 sample-hash hash2 ] unit-test
[ "other" ] [ 4 7 sample-hash hash2 ] unit-test
[ f ] [ 4 12 sample-hash hash2 ] unit-test
[ f ] [ 1 1 sample-hash hash2 ] unit-test

! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test combinators.smart math kernel accessors ;
IN: combinators.smart.tests

: test-bi ( -- 9 11 )
    10 [ 1- ] [ 1+ ] bi ;

[ [ test-bi ] output>array ] must-infer
[ { 9 11 } ] [ [ test-bi ] output>array ] unit-test

[ { 9 11 } [ + ] input<sequence ] must-infer
[ 20 ] [ { 9 11 } [ + ] input<sequence ] unit-test

[ 6 ] [ [ 1 2 3 ] [ + ] reduce-outputs ] unit-test

[ [ 1 2 3 ] [ + ] reduce-outputs ] must-infer

[ 6 ] [ [ 1 2 3 ] sum-outputs ] unit-test

[ "ab" ]
[
    [ "a" "b" ] "" append-outputs-as
] unit-test

[ "" ]
[
    [ ] "" append-outputs-as
] unit-test

[ { } ]
[
    [ ] append-outputs
] unit-test

[ B{ 1 2 3 } ]
[
    [ { 1 } { 2 } { 3 } ] B{ } append-outputs-as
] unit-test

! Test nesting
: nested-smart-combo-test ( -- array )
    [ [ 1 2 ] output>array [ 3 4 ] output>array ] output>array ;

\ nested-smart-combo-test def>> must-infer

[ { { 1 2 } { 3 4 } } ] [ nested-smart-combo-test ] unit-test

[ 14 ] [ [ 1 2 3 ] [ sq ] [ + ] map-reduce-outputs ] unit-test
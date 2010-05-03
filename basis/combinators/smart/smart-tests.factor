! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.smart kernel math
tools.test ;
IN: combinators.smart.tests

: test-bi ( -- 9 11 )
    10 [ 1 - ] [ 1 + ] bi ;

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

{ 2 3 } [ [ + ] preserving ] must-infer-as

{ 2 0 } [ [ + ] nullary ] must-infer-as

{ 2 2 } [ [ [ + ] nullary ] preserving ] must-infer-as

: smart-if-test ( a b -- b )
    [ < ] [ swap - ] [ - ] smart-if ;

[ 7 ] [ 10 3 smart-if-test ] unit-test
[ 16 ] [ 25 41 smart-if-test ] unit-test

[ { 1 2 } { 3 4 } { 5 6 } ] [ 1 2 3 4 5 6 [ 2array ] 3 smart-apply ] unit-test
[ { 1 2 3 } { 4 5 6 } ] [ 1 2 3 4 5 6 [ 3array ] 2 smart-apply ] unit-test

[ 4 ] [ 2 [ even? ] [ 2 + ] smart-when ] unit-test
[ 3 ] [ 3 [ even? ] [ 2 + ] smart-when ] unit-test
[ 4 ] [ 2 [ odd? ] [ 2 + ] smart-unless ] unit-test
[ 3 ] [ 3 [ odd? ] [ 2 + ] smart-unless ] unit-test

[ 4 ] [ 2 [ even? ] [ 2 + ] smart-when* ] unit-test
[ ] [ 3 [ even? ] [ 2 + ] smart-when* ] unit-test
[ 3 ] [ 2 [ odd? ] [ 3 ] smart-unless* ] unit-test
[ 3 ] [ 3 [ odd? ] [ 5 ] smart-unless* ] unit-test

[ -1 ] [ 1 2 [ + odd? ] [ - ] smart-when* ] unit-test
[ ] [ 2 2 [ + odd? ] [ ] smart-unless* ] unit-test

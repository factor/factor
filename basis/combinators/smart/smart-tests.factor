! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.smart kernel
math random sequences stack-checker tools.test ;
IN: combinators.smart.tests

: test-bi ( -- 9 11 )
    10 [ 1 - ] [ 1 + ] bi ;

[ [ test-bi ] output>array ] must-infer
{ { 9 11 } } [ [ test-bi ] output>array ] unit-test

[ { 9 11 } [ + ] input<sequence ] must-infer
{ 20 } [ { 9 11 } [ + ] input<sequence ] unit-test

{ 6 } [ [ 1 2 3 ] [ + ] reduce-outputs ] unit-test

[ [ 1 2 3 ] [ + ] reduce-outputs ] must-infer

{ 6 } [ [ 1 2 3 ] sum-outputs ] unit-test

{ "ab" }
[
    [ "a" "b" ] "" append-outputs-as
] unit-test

{ "" }
[
    [ ] "" append-outputs-as
] unit-test

{ { } }
[
    [ ] append-outputs
] unit-test

{ B{ 1 2 3 } }
[
    [ { 1 } { 2 } { 3 } ] B{ } append-outputs-as
] unit-test

! Test nesting
: nested-smart-combo-test ( -- array )
    [ [ 1 2 ] output>array [ 3 4 ] output>array ] output>array ;

\ nested-smart-combo-test def>> must-infer

{ { { 1 2 } { 3 4 } } } [ nested-smart-combo-test ] unit-test

{ 14 } [ [ 1 2 3 ] [ sq ] [ + ] map-reduce-outputs ] unit-test

{ 2 3 } [ [ + ] preserving ] must-infer-as

{ 2 0 } [ [ + ] nullary ] must-infer-as

{ 2 2 } [ [ [ + ] nullary ] preserving ] must-infer-as

: smart-if-test ( a b -- b )
    [ < ] [ swap - ] [ - ] smart-if ;

{ 7 } [ 10 3 smart-if-test ] unit-test
{ 16 } [ 25 41 smart-if-test ] unit-test

{ { 1 2 } { 3 4 } { 5 6 } } [ 1 2 3 4 5 6 [ 2array ] 3 smart-apply ] unit-test
{ { 1 2 3 } { 4 5 6 } } [ 1 2 3 4 5 6 [ 3array ] 2 smart-apply ] unit-test

{ 4 } [ 2 [ even? ] [ 2 + ] smart-when ] unit-test
{ 3 } [ 3 [ even? ] [ 2 + ] smart-when ] unit-test
{ 4 } [ 2 [ odd? ] [ 2 + ] smart-unless ] unit-test
{ 3 } [ 3 [ odd? ] [ 2 + ] smart-unless ] unit-test

{ 4 } [ 2 [ even? ] [ 2 + ] smart-when* ] unit-test
{ } [ 3 [ even? ] [ 2 + ] smart-when* ] unit-test
{ 3 } [ 2 [ odd? ] [ 3 ] smart-unless* ] unit-test
{ 3 } [ 3 [ odd? ] [ 5 ] smart-unless* ] unit-test

{ -1 } [ 1 2 [ + odd? ] [ - ] smart-when* ] unit-test
{ } [ 2 2 [ + odd? ] [ ] smart-unless* ] unit-test

{ ( -- x ) } [ [ [ ] [ call ] curry output>array ] infer ] unit-test

:: map-reduce-test ( a b c -- d ) [ a b c ] [ a - ] [ b * + ] map-reduce-outputs ;

{ 10 } [ 1 2 3 map-reduce-test ] unit-test

{ ( x x -- x ) } [ [ curry inputs ] infer ] unit-test

{ ( x -- x ) } [ [ [ curry ] curry inputs ] infer ] unit-test

{ 1 1 1 } [ 1 3 [ ] smart-with times ] unit-test
{ "BCD" } [ 1 "ABC" [ + ] smart-with map ] unit-test
{ H{ { 1 2 } } } [ 1 H{ { 1 2 } { 3 4 } } [ = ] smart-with filter-keys ] unit-test

: test-cleave>sequence ( obj -- seq )  { [ 1 + ] [ sq ] [ 1 - ] } V{ } cleave>sequence ;
\ test-cleave>sequence def>> must-infer

{ V{ 34 1089 32 } } [ 33 test-cleave>sequence ] unit-test

{ 60 6000 } [
    { 10 20 30 } {
        { 0 [ + ] }
        { 1 [ * ] }
    } smart-reduce
] unit-test

{ 1400 60 } [
    { 10 20 30 } {
        { [ sq ] [ + ] }
        { [ ] [ + ] }
    } smart-map-reduce
] unit-test

{ 0 12 } [
    { 1 2 3 } dup {
        { 0 [ - + ] }
        { 0 [ + + ] }
    } smart-2reduce
] unit-test

{ 36 12 } [
    { 1 2 3 } dup {
        { [ * ] [ * ] }
        { [ + ] [ + ] }
    } smart-2map-reduce
] unit-test

{ { 1 2 3 4 } 5 6 } [ [ 1 2 3 4 5 6 ] 2 output>array-n ] unit-test
{ { } 5 6 } [ [ 5 6 ] 2 output>array-n ] unit-test
{ { 1 2 } 3 4 5 6 } [ [ 1 2 3 4 5 6 ] 4 output>array-n ] unit-test

{ t } [ [ 10 random dup even? ] smart-loop odd? ] unit-test

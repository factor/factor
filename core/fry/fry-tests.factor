! Copyright (C) 2009 Slava Pestov, Eduardo Cavazos, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: fry tools.test math prettyprint kernel io arrays
sequences eval accessors ;
IN: fry.tests

SYMBOLS: a b c d e f g h ;

{ [ ] } [ '[ ] ] unit-test
{ [ + ] } [ '[ + ] ] unit-test
{ [ 1 ] } [ 1 '[ _ ] ] unit-test
{ [ 1 ] } [ [ 1 ] '[ @ ] ] unit-test
{ [ 1 2 ] } [ [ 1 ] [ 2 ] '[ @ @ ] ] unit-test

{ [ 1 2 a ] } [ 1 2 '[ _ _ a ] ] unit-test
{ [ 1 2 ] } [ 1 2 '[ _ _ ] ] unit-test
{ [ a 1 2 ] } [ 1 2 '[ a _ _ ] ] unit-test
{ [ 1 2 a ] } [ [ 1 ] [ 2 ] '[ @ @ a ] ] unit-test
{ [ 1 a 2 b ] } [ 1 2 '[ _ a _ b ] ] unit-test
{ [ 1 a 2 b ] } [ 1 [ 2 ] '[ _ a @ b ] ] unit-test
{ [ a 1 b ] } [ 1 '[ a _ b ] ] unit-test

{ [ a 1 b ] } [ [ 1 ] '[ a @ b ] ] unit-test
{ [ a 1 2 ] } [ [ 1 ] [ 2 ] '[ a @ @ ] ] unit-test

{ [ a [ 1 ] b ] } [ 1 '[ a [ _ ] b ] ] unit-test
{ [ a 1 b [ c 2 d ] e 3 f ] } [ 1 2 3 '[ a _ b [ c _ d ] e _ f ] ] unit-test
{ [ a 1 b [ c 2 d [ e 3 f ] ] g 4 h ] } [ 1 2 3 4 '[ a _ b [ c _ d [ e _ f ] ] g _ h ] ] unit-test
{ [ a 1 b [ [ c 2 d ] e 3 f ] g 4 h ] } [ 1 2 3 4 '[ a _ b [ [ c _ d ] e _ f ] g _ h ] ] unit-test

{ [ 3 + ] } [ 3 '[ _ + ] ] unit-test

{ [ 1 3 + ] } [ 1 3 '[ _ _ + ] ] unit-test

{ [ 1 + ] } [ 1 [ + ] '[ _ @ ] ] unit-test

{ [ 1 + . ] } [ 1 [ + ] '[ _ @ . ] ] unit-test

{ [ + - ] } [ [ + ] [ - ] '[ @ @ ] ] unit-test

{ [ "a" write "b" print ] }
[ "a" "b" '[ _ write _ print ] ] unit-test

{ 1/2 } [
    1 '[ [ _ ] dip / ] 2 swap call
] unit-test

{ { { 1 "a" "A" } { 1 "b" "B" } { 1 "c" "C" } } } [
    1 '[ [ _ ] 2dip 3array ]
    { "a" "b" "c" } { "A" "B" "C" } rot 2map
] unit-test

{ { { 1 "a" } { 1 "b" } { 1 "c" } } } [
    '[ [ 1 ] dip 2array ]
    { "a" "b" "c" } swap map
] unit-test

{ { { 1 "a" 2 } { 1 "b" 2 } { 1 "c" 2 } } } [
    1 2 '[ [ _ ] dip _ 3array ]
    { "a" "b" "c" } swap map
] unit-test

: funny-dip ( obj quot -- ) '[ [ @ ] dip ] call ; inline

{ "hi" 3 } [ "h" "i" 3 [ append ] funny-dip ] unit-test

{ { 1 2 3 } } [
    3 1 '[ _ <iota> [ _ + ] map ] call
] unit-test

{ { 1 { 2 { 3 } } } } [
    1 2 3 '[ _ [ _ [ _ 1array ] call 2array ] call 2array ] call
] unit-test

{ 1 1 } [ '[ [ [ _ ] ] ] ] must-infer-as

{ { { { 3 } } } } [
    3 '[ [ [ _ 1array ] call 1array ] call 1array ] call
] unit-test

{ { { { 3 } } } } [
    3 '[ [ [ _ 1array ] call 1array ] call 1array ] call
] unit-test

[ "USING: fry locals.backend ; f '[ load-local _ ]" eval( -- quot ) ]
[ error>> >r/r>-in-fry-error? ] must-fail-with

{ { { "a" 1 } { "b" 2 } { "c" 3 } { "d" 4 } } } [
    1 2 3 4 '[ "a" _ 2array "b" _ 2array "c" _ 2array "d" _ 2array 4array ] call
] unit-test

{ { 1 [ 2 { 3 4 } ] } } [ 1 2 3 4 '{ _ [ _ { _ _ } ] } ] unit-test
{ H{ { 1 1 } { 2 2 } { 3 4 } } } [ 1 2 3 4 'H{ { 1 _ } { _ 2 } { _ _ } } ] unit-test
{ HS{ 1 [ 2 { 3 } ] } } [ 1 2 3 'HS{ _ [ _ { _ } ] } ] unit-test

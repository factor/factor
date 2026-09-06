! Copyright (C) 2007, 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: inverse tools.test arrays math kernel sequences
math.functions math.constants continuations combinators.smart locals ;
IN: inverse.tests

! #119: captured locals are values, not words to expand while inverting.
:: un-add-local ( n a -- b ) n [ a - ] undo ;
:: un-subtract-local ( n a -- b ) n [ a + ] undo ;
:: un-divide-local ( n a -- b ) n [ a / ] undo ;
:: un-left-subtract-local ( n a -- b ) n [ a swap - ] undo ;

{ 14 } [ 10 4 un-add-local ] unit-test
{ 6 } [ 10 4 un-subtract-local ] unit-test
{ 40 } [ 10 4 un-divide-local ] unit-test
{ 6 } [ 4 10 un-left-subtract-local ] unit-test

:: un-affine-local ( n a b -- m ) n [ a * b + ] undo ;
{ 5 } [ 13 2 3 un-affine-local ] unit-test
{ } [ { 4 5 } 4 5 [| obj a b | obj [ a b 2array ] undo ] call ] unit-test

{ 15 } [ [let 4 :> a! 5 a! 10 [ a - ] undo ] ] unit-test
{ } [ 4 [| a | 4 [ a ] undo ] call ] unit-test
[ 4 [| a | 5 [ a ] undo ] call ] [ fail? ] must-fail-with
{ } [ [let 4 :> a! 4 [ a ] undo ] ] unit-test
[ [let 4 :> a! 5 [ a ] undo ] ] [ fail? ] must-fail-with

{ 2 } [ { 3 2 } [ 3 swap 2array ] undo ] unit-test
[ { 3 4 } [ dup 2array ] undo ] must-fail

TUPLE: foo bar baz ;

C: <foo> foo

{ 1 2 } [ 1 2 <foo> [ <foo> ] undo ] unit-test

: 2same ( x -- {x,x} ) dup 2array ;

{ t } [ { 3 3 } [ 2same ] matches? ] unit-test
{ f } [ { 3 4 } [ 2same ] matches? ] unit-test
[ [ 2same ] matches? ] must-fail

: something ( array -- num )
    {
        { [ dup 1 + 2array ] [ 3 * ] }
        { [ 3array ] [ + + ] }
    } switch ;

{ 5 } [ { 1 2 2 } something ] unit-test
{ 6 } [ { 2 3 } something ] unit-test
[ { 1 } something ] must-fail

[ 1 2 [ eq? ] undo ] must-fail

: f>c ( *fahrenheit -- *celsius )
    32 - 1.8 / ;

{ { 212.0 32.0 } } [ { 100 0 } [ [ f>c ] map ] undo ] unit-test
{ { t t f } } [ { t f 1 } [ [ >boolean ] matches? ] map ] unit-test
{ { t f } } [ { { 1 2 3 } 4 } [ [ >array ] matches? ] map ] unit-test
{ 9 9 } [ 3 [ 1/2 ^ ] undo 3 [ sqrt ] undo ] unit-test
{ 5 } [ 6 5 - [ 6 swap - ] undo ] unit-test
{ 6 } [ 6 5 - [ 5 - ] undo ] unit-test

TUPLE: cons car cdr ;

C: <cons> cons

TUPLE: nil ;

C: <nil> nil

: list-sum ( list -- sum )
    {
        { [ <cons> ] [ list-sum + ] }
        { [ <nil> ] [ 0 ] }
        [ "Malformed list" throw ]
    } switch ;

{ 10 } [ 1 2 3 4 <nil> <cons> <cons> <cons> <cons> list-sum ] unit-test
{ } [ <nil> [ <nil> ] undo ] unit-test
{ 1 2 } [ 1 2 <cons> [ <cons> ] undo ] unit-test
{ t } [ 1 2 <cons> [ <cons> ] matches? ] unit-test
{ f } [ 1 2 <cons> [ <foo> ] matches? ] unit-test
{ "Malformed list" } [ [ f list-sum ] [ ] recover ] unit-test

: empty-cons ( -- cons ) cons new ;
: cons* ( cdr car -- cons ) cons boa ;

{ } [ T{ cons f f f } [ empty-cons ] undo ] unit-test
{ 1 2 } [ 1 2 <cons> [ cons* ] undo ] unit-test

{ t } [ pi [ pi ] matches? ] unit-test
{ 0.0 } [ 0.0 pi + [ pi + ] undo ] unit-test
{ } [ 3 [ __ ] undo ] unit-test

{ 2 } [ 4 [ 2 swap + ] undo ] unit-test
{ 2 } [ 4 [ 2 swap * ] undo ] unit-test

{ 2.0 } [ 2 3 ^ [ 3 ^ ] undo ] unit-test
{ 3.0 } [ 2 3 ^ [ 2 swap ^ ] undo ] unit-test

{ { 1 } } [ { 1 2 3 } [ { 2 3 } append ] undo ] unit-test
{ { 3 } } [ { 1 2 3 } [ { 1 2 } prepend ] undo ] unit-test
[ { 1 2 3 } [ { 1 2 } append ] undo ] must-fail
[ { 1 2 3 } [ { 2 3 } prepend ] undo ] must-fail

{ [ sq ] } [ [ sqrt ] [undo] ] unit-test
{ [ sqrt ] } [ [ sq ] [undo] ] unit-test
{ [ not ] } [ [ not ] [undo] ] unit-test
{ { 3 2 1 } } [ { 1 2 3 } [ reverse ] undo ] unit-test

TUPLE: funny-tuple ;
: <funny-tuple> ( -- funny-tuple ) \ funny-tuple boa ;
: funny-tuple ( -- ) "OOPS" throw ;

{ } [ [ <funny-tuple> ] [undo] drop ] unit-test

{ 0 } [ { 1 2 } [ [ 1 + 2 ] { } output>sequence ] undo ] unit-test
{ { 0 1 } } [ 1 2 [ [ [ 1 + ] bi@ ] input<sequence ] undo ] unit-test

{ 123.46 } [ 123.456 [ 100 * ] [ round ] under ] unit-test

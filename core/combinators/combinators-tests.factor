USING: accessors arrays combinators combinators.private io
kernel math math.functions prettyprint sequences stack-checker
tools.test words ;
IN: combinators.tests

{ 3 } [ 1 2 [ + ] call( x y -- z ) ] unit-test
[ 1 2 [ + ] call( -- z ) ] must-fail
[ 1 2 [ + ] call( x y -- z a ) ] must-fail
{ 1 2 3 { 1 2 3 4 } } [ 1 2 3 4 [ get-datastack nip ] call( x -- y ) ] unit-test
[ [ + ] call( x y -- z ) ] must-infer

{ 3 } [ 1 2 \ + execute( x y -- z ) ] unit-test
[ 1 2 \ + execute( -- z ) ] must-fail
[ 1 2 \ + execute( x y -- z a ) ] must-fail
[ \ + execute( x y -- z ) ] must-infer

: compile-execute(-test-1 ( a b -- c ) \ + execute( a b -- c ) ;

{ t } [ \ compile-execute(-test-1 word-optimized? ] unit-test
{ 4 } [ 1 3 compile-execute(-test-1 ] unit-test

: compile-execute(-test-2 ( a b w -- c ) execute( a b -- c ) ;

{ t } [ \ compile-execute(-test-2 word-optimized? ] unit-test
{ 4 } [ 1 3 \ + compile-execute(-test-2 ] unit-test
{ 5 } [ 1 4 \ + compile-execute(-test-2 ] unit-test
{ -3 } [ 1 4 \ - compile-execute(-test-2 ] unit-test
{ 5 } [ 1 4 \ + compile-execute(-test-2 ] unit-test

: compile-call(-test-1 ( a b q -- c ) call( a b -- c ) ;

{ t } [ \ compile-call(-test-1 word-optimized? ] unit-test
{ 4 } [ 1 3 [ + ] compile-call(-test-1 ] unit-test
{ 7 } [ 1 3 2 [ * + ] curry compile-call(-test-1 ] unit-test
{ 7 } [ 1 3 [ 2 * ] [ + ] compose compile-call(-test-1 ] unit-test
{ 4 } [ 1 3 [ { + } [ ] like call ] compile-call(-test-1 ] unit-test

[ [ ] call( -- * ) ] must-fail

: compile-call(-test-2 ( -- ) [ ] call( -- * ) ;

[ compile-call(-test-2 ] [ wrong-values? ] must-fail-with

: compile-call(-test-3 ( quot -- ) call( -- * ) ;

[ [ ] compile-call(-test-3 ] [ wrong-values? ] must-fail-with

: compile-execute(-test-3 ( a -- ) \ . execute( value -- * ) ;

[ 10 compile-execute(-test-3 ] [ wrong-values? ] must-fail-with

: compile-execute(-test-4 ( a word -- ) execute( value -- * ) ;

[ 10 \ . compile-execute(-test-4 ] [ wrong-values? ] must-fail-with

! Cond
: cond-test-1 ( obj -- str )
    {
        { [ dup 2 mod 0 = ] [ drop "even" ] }
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
    } cond ;

\ cond-test-1 def>> must-infer

{ "even" } [ 2 cond-test-1 ] unit-test
{ "even" } [ 2 \ cond-test-1 def>> call ] unit-test
{ "odd" } [ 3 cond-test-1 ] unit-test
{ "odd" } [ 3 \ cond-test-1 def>> call ] unit-test

: cond-test-2 ( obj -- str )
    {
        { [ dup t = ] [ drop "true" ] }
        { [ dup f = ] [ drop "false" ] }
        [ drop "something else" ]
    } cond ;

\ cond-test-2 def>> must-infer

{ "true" } [ t cond-test-2 ] unit-test
{ "true" } [ t \ cond-test-2 def>> call ] unit-test
{ "false" } [ f cond-test-2 ] unit-test
{ "false" } [ f \ cond-test-2 def>> call ] unit-test
{ "something else" } [ "ohio" cond-test-2 ] unit-test
{ "something else" } [ "ohio" \ cond-test-2 def>> call ] unit-test

: cond-test-3 ( obj -- str )
    {
        [ drop "something else" ]
        { [ dup t = ] [ drop "true" ] }
        { [ dup f = ] [ drop "false" ] }
    } cond ;

\ cond-test-3 def>> must-infer

{ "something else" } [ t cond-test-3 ] unit-test
{ "something else" } [ t \ cond-test-3 def>> call ] unit-test
{ "something else" } [ f cond-test-3 ] unit-test
{ "something else" } [ f \ cond-test-3 def>> call ] unit-test
{ "something else" } [ "ohio" cond-test-3 ] unit-test
{ "something else" } [ "ohio" \ cond-test-3 def>> call ] unit-test

: cond-test-4 ( -- )
    {
    } cond ;

\ cond-test-4 def>> must-infer

[ cond-test-4 ] [ no-cond? ] must-fail-with
[ \ cond-test-4 def>> call ] [ no-cond? ] must-fail-with

: cond-test-5 ( a -- b )
    {
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
        [ drop "early" ]
        { [ dup 2 mod 0 = ] [ drop "even" ] }
    } cond ;

{ "early" } [ 2 cond-test-5 ] unit-test
{ "early" } [ 2 \ cond-test-5 def>> call ] unit-test

: cond-test-6 ( a -- b )
    {
        [ drop "really early" ]
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
        { [ dup 2 mod 0 = ] [ drop "even" ] }
    } cond ;

{ "really early" } [ 2 cond-test-6 ] unit-test
{ "really early" } [ 2 \ cond-test-6 def>> call ] unit-test

! Case
: case-test-1 ( obj -- obj' )
    {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
        { 4 [ "four" ] }
    } case ;

\ case-test-1 def>> must-infer

{ "two" } [ 2 case-test-1 ] unit-test
{ "two" } [ 2 \ case-test-1 def>> call ] unit-test

[ "x" case-test-1 ] must-fail
[ "x" \ case-test-1 def>> call ] must-fail

: case-test-2 ( obj -- obj' )
    {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
        { 4 [ "four" ] }
        [ sq ]
    } case ;

\ case-test-2 def>> must-infer

{ 25 } [ 5 case-test-2 ] unit-test
{ 25 } [ 5 \ case-test-2 def>> call ] unit-test

: case-test-3 ( obj -- obj' )
    {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
        { 4 [ "four" ] }
        { H{ } [ "a hashtable" ] }
        { { 1 2 3 } [ "an array" ] }
        [ sq ]
    } case ;

\ case-test-3 def>> must-infer

{ "an array" } [ { 1 2 3 } case-test-3 ] unit-test
{ "an array" } [ { 1 2 3 } \ case-test-3 def>> call ] unit-test

CONSTANT: case-const-1 1
CONSTANT: case-const-2 2

! Compiled
: case-test-4 ( obj -- str )
    {
        { case-const-1 [ "uno" ] }
        { case-const-2 [ "dos" ] }
        { 3 [ "tres" ] }
        { 4 [ "cuatro" ] }
        { 5 [ "cinco" ] }
        [ drop "demasiado" ]
    } case ;

\ case-test-4 def>> must-infer

{ "uno" } [ 1 case-test-4 ] unit-test
{ "dos" } [ 2 case-test-4 ] unit-test
{ "tres" } [ 3 case-test-4 ] unit-test
{ "demasiado" } [ 100 case-test-4 ] unit-test

{ "uno" } [ 1 \ case-test-4 def>> call ] unit-test
{ "dos" } [ 2 \ case-test-4 def>> call ] unit-test
{ "tres" } [ 3 \ case-test-4 def>> call ] unit-test
{ "demasiado" } [ 100 \ case-test-4 def>> call ] unit-test

: case-test-5 ( obj -- )
    {
        { case-const-1 [ "uno" print ] }
        { case-const-2 [ "dos" print ] }
        { 3 [ "tres" print ] }
        { 4 [ "cuatro" print ] }
        { 5 [ "cinco" print ] }
        [ drop "demasiado" print ]
    } case ;

\ case-test-5 def>> must-infer

{ } [ 1 case-test-5 ] unit-test
{ } [ 1 \ case-test-5 def>> call ] unit-test

: do-not-call ( -- * ) "do not call" throw ;

: test-case-6 ( obj -- value )
    {
        { \ do-not-call [ "do-not-call" ] }
        { 3 [ "three" ] }
    } case ;

\ test-case-6 def>> must-infer

{ "three" } [ 3 test-case-6 ] unit-test
{ "do-not-call" } [ \ do-not-call test-case-6 ] unit-test

{ t } [ { 1 3 2 } contiguous-range? ] unit-test
{ f } [ { 1 2 2 4 } contiguous-range? ] unit-test
{ f } [ { + 3 2 } contiguous-range? ] unit-test
{ f } [ { 1 0 7 } contiguous-range? ] unit-test
{ f } [ { 1 1 3 7 } contiguous-range? ] unit-test
{ t } [ { 7 6 4 8 5 } contiguous-range? ] unit-test


: test-case-7 ( obj -- str )
    {
        { \ + [ "plus" ] }
        { \ - [ "minus" ] }
        { \ * [ "times" ] }
        { \ / [ "divide" ] }
        { \ ^ [ "power" ] }
        { \ [ [ "obama" ] }
    } case ;

\ test-case-7 def>> must-infer

{ "plus" } [ \ + test-case-7 ] unit-test
{ "plus" } [ \ + \ test-case-7 def>> call ] unit-test

DEFER: corner-case-1

<< \ corner-case-1 2 [ + ] curry 1array [ case ] curry ( a -- b ) define-declared >>

{ t } [ \ corner-case-1 word-optimized? ] unit-test

{ 4 } [ 2 corner-case-1 ] unit-test
{ 4 } [ 2 \ corner-case-1 def>> call ] unit-test

: test-case-8 ( n -- string )
    {
        { 1 [ "foo" ] }
    } case ;

[ 3 test-case-8 ] [ object>> 3 = ] must-fail-with
[ 3 \ test-case-8 def>> call ] [ object>> 3 = ] must-fail-with

: test-case-9 ( a -- b )
    {
        { \ + [ "plus" ] }
        { \ + [ "plus 2" ] }
        { \ - [ "minus" ] }
        { \ - [ "minus 2" ] }
    } case ;

{ "plus" } [ \ + test-case-9 ] unit-test
{ "plus" } [ \ + \ test-case-9 def>> call ] unit-test

{ "minus" } [ \ - test-case-9 ] unit-test
{ "minus" } [ \ - \ test-case-9 def>> call ] unit-test

: test-case-10 ( a -- b )
    {
        { 1 [ "uno" ] }
        { 2 [ "dos" ] }
        { 2 [ "DOS" ] }
        { 3 [ "tres" ] }
        { 4 [ "cuatro" ] }
        { 5 [ "cinco" ] }
    } case ;

{ "dos" } [ 2 test-case-10 ] unit-test
{ "dos" } [ 2 \ test-case-10 def>> call ] unit-test

: test-case-11 ( a -- b )
    {
        { 11 [ "uno" ] }
        { 22 [ "dos" ] }
        { 22 [ "DOS" ] }
        { 33 [ "tres" ] }
        { 44 [ "cuatro" ] }
        { 55 [ "cinco" ] }
    } case ;

{ "dos" } [ 22 test-case-11 ] unit-test
{ "dos" } [ 22 \ test-case-11 def>> call ] unit-test

: test-case-12 ( a -- b )
    {
        { 11 [ "uno" ] }
        { 22 [ "dos" ] }
        [ drop "nachos" ]
        { 33 [ "tres" ] }
        { 44 [ "cuatro" ] }
        { 55 [ "cinco" ] }
    } case ;

{ "nachos" } [ 33 test-case-12 ] unit-test
{ "nachos" } [ 33 \ test-case-12 def>> call ] unit-test

{ ( x x -- x x ) } [
    [ { [ ] [ ] } spread ] infer
] unit-test

: test-case-13 ( a -- b )
    {
        { 5 [ 5 ] }
        { 6 [ 6 ] }
        { 7 [ 7 ] }
        { 8 [ 8 ] }
        { 9 [ 9 ] }
    } case ;

[ 5.0 test-case-13 ] [ no-case? ] must-fail-with

{
    [
        dup 1 =
        [ drop "one" ] [
            dup 2 =
            [ drop "two" ]
            [ dup 3 = [ drop "three" ] [ drop f ] if ] if
        ] if
    ]
} [
    [ drop f ] {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
    } linear-case-quot
] unit-test

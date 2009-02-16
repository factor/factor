USING: alien strings kernel math tools.test io prettyprint
namespaces combinators words classes sequences accessors 
math.functions arrays ;
IN: combinators.tests

! Compiled
: cond-test-1 ( obj -- str )
    {
        { [ dup 2 mod 0 = ] [ drop "even" ] }
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
    } cond ;

\ cond-test-1 must-infer

[ "even" ] [ 2 cond-test-1 ] unit-test
[ "odd" ] [ 3 cond-test-1 ] unit-test

: cond-test-2 ( obj -- str )
    {
        { [ dup t = ] [ drop "true" ] }
        { [ dup f = ] [ drop "false" ] }
        [ drop "something else" ]
    } cond ;

\ cond-test-2 must-infer

[ "true" ] [ t cond-test-2 ] unit-test
[ "false" ] [ f cond-test-2 ] unit-test
[ "something else" ] [ "ohio" cond-test-2 ] unit-test

: cond-test-3 ( obj -- str )
    {
        [ drop "something else" ]
        { [ dup t = ] [ drop "true" ] }
        { [ dup f = ] [ drop "false" ] }
    } cond ;

\ cond-test-3 must-infer

[ "something else" ] [ t cond-test-3 ] unit-test
[ "something else" ] [ f cond-test-3 ] unit-test
[ "something else" ] [ "ohio" cond-test-3 ] unit-test

: cond-test-4 ( -- )
    {
    } cond ;

\ cond-test-4 must-infer

[ cond-test-4 ] [ class \ no-cond = ] must-fail-with

! Interpreted
[ "even" ] [
    2 {
        { [ dup 2 mod 0 = ] [ drop "even" ] }
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
    } cond
] unit-test

[ "odd" ] [
    3 {
        { [ dup 2 mod 0 = ] [ drop "even" ] }
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
    } cond
] unit-test

[ "neither" ] [
    3 {
        { [ dup string? ] [ drop "string" ] }
        { [ dup float? ] [ drop "float" ] }
        { [ dup alien? ] [ drop "alien" ] }
        [ drop "neither" ]
    } cond
] unit-test

[ "neither" ] [
    3 {
        { [ dup string? ] [ drop "string" ] }
        { [ dup float? ] [ drop "float" ] }
        { [ dup alien? ] [ drop "alien" ] }
        [ drop "neither" ]
    } cond
] unit-test

[ "neither" ] [
    3 {
        { [ dup string? ] [ drop "string" ] }
        { [ dup float? ] [ drop "float" ] }
        { [ dup alien? ] [ drop "alien" ] }
        [ drop "neither" ]
    } cond
] unit-test

[ "early" ] [
    2 {
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
        [ drop "early" ]
        { [ dup 2 mod 0 = ] [ drop "even" ] }
    } cond
] unit-test

[ "really early" ] [
    2 {
       [ drop "really early" ]
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
        { [ dup 2 mod 0 = ] [ drop "even" ] }
    } cond
] unit-test

[ { } cond ] [ class \ no-cond = ] must-fail-with
 
[ "early" ] [
    2 {
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
        [ drop "early" ]
        { [ dup 2 mod 0 = ] [ drop "even" ] }
    } cond
] unit-test

[ "really early" ] [
    2 {
        [ drop "really early" ]
        { [ dup 2 mod 1 = ] [ drop "odd" ] }
        { [ dup 2 mod 0 = ] [ drop "even" ] }
    } cond
] unit-test

[ { } cond ] [ class \ no-cond = ] must-fail-with

! Compiled
: case-test-1 ( obj -- obj' )
    {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
        { 4 [ "four" ] }
    } case ;

\ case-test-1 must-infer

[ "two" ] [ 2 case-test-1 ] unit-test

! Interpreted
[ "two" ] [ 2 \ case-test-1 def>> call ] unit-test

[ "x" case-test-1 ] must-fail

: case-test-2 ( obj -- obj' )
    {
        { 1 [ "one" ] }
        { 2 [ "two" ] }
        { 3 [ "three" ] }
        { 4 [ "four" ] }
        [ sq ]
    } case ;

\ case-test-2 must-infer

[ 25 ] [ 5 case-test-2 ] unit-test

! Interpreted
[ 25 ] [ 5 \ case-test-2 def>> call ] unit-test

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

\ case-test-3 must-infer

[ "an array" ] [ { 1 2 3 } case-test-3 ] unit-test

: case-const-1 1 ;
: case-const-2 2 ; inline

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

\ case-test-4 must-infer

[ "uno" ] [ 1 case-test-4 ] unit-test
[ "dos" ] [ 2 case-test-4 ] unit-test
[ "tres" ] [ 3 case-test-4 ] unit-test
[ "demasiado" ] [ 100 case-test-4 ] unit-test

: case-test-5 ( obj -- )
    {
        { case-const-1 [ "uno" print ] }
        { case-const-2 [ "dos" print ] }
        { 3 [ "tres" print ] } 
        { 4 [ "cuatro" print ] } 
        { 5 [ "cinco" print ] } 
        [ drop "demasiado" print ]
    } case ;

\ case-test-5 must-infer

[ ] [ 1 case-test-5 ] unit-test

! Interpreted
[ "uno" ] [
    1 {
        { case-const-1 [ "uno" ] }
        { case-const-2 [ "dos" ] }
        { 3 [ "tres" ] } 
        { 4 [ "cuatro" ] } 
        { 5 [ "cinco" ] } 
        [ drop "demasiado" ]
    } case
] unit-test

[ "dos" ] [
    2 {
        { case-const-1 [ "uno" ] }
        { case-const-2 [ "dos" ] }
        { 3 [ "tres" ] } 
        { 4 [ "cuatro" ] } 
        { 5 [ "cinco" ] } 
        [ drop "demasiado" ]
    } case
] unit-test

[ "tres" ] [
    3 {
        { case-const-1 [ "uno" ] }
        { case-const-2 [ "dos" ] }
        { 3 [ "tres" ] } 
        { 4 [ "cuatro" ] } 
        { 5 [ "cinco" ] } 
        [ drop "demasiado" ]
    } case
] unit-test

[ "demasiado" ] [
    100 {
        { case-const-1 [ "uno" ] }
        { case-const-2 [ "dos" ] }
        { 3 [ "tres" ] } 
        { 4 [ "cuatro" ] } 
        { 5 [ "cinco" ] } 
        [ drop "demasiado" ]
    } case
] unit-test

: do-not-call "do not call" throw ;

: test-case-6 ( obj -- value )
    {
        { \ do-not-call [ "do-not-call" ] }
        { 3 [ "three" ] }
    } case ;

\ test-case-6 must-infer

[ "three" ] [ 3 test-case-6 ] unit-test
[ "do-not-call" ] [ \ do-not-call test-case-6 ] unit-test

[ "three" ] [
    3 {
        { \ do-not-call [ "do-not-call" ] }
        { 3 [ "three" ] }
    } case
] unit-test

[ "do-not-call" ] [
    [ do-not-call ] first {
        { \ do-not-call [ "do-not-call" ] }
        { 3 [ "three" ] }
    } case
] unit-test

[ "do-not-call" ] [
    \ do-not-call {
        { \ do-not-call [ "do-not-call" ] }
        { 3 [ "three" ] }
    } case
] unit-test

! Interpreted
[ "a hashtable" ] [ H{ } \ case-test-3 def>> call ] unit-test

[ t ] [ { 1 3 2 } contiguous-range? ] unit-test
[ f ] [ { 1 2 2 4 } contiguous-range? ] unit-test
[ f ] [ { + 3 2 } contiguous-range? ] unit-test
[ f ] [ { 1 0 7 } contiguous-range? ] unit-test
[ f ] [ { 1 1 3 7 } contiguous-range? ] unit-test
[ t ] [ { 7 6 4 8 5 } contiguous-range? ] unit-test

: test-case-7 ( obj -- str )
    {
        { \ + [ "plus" ] }
        { \ - [ "minus" ] }
        { \ * [ "times" ] }
        { \ / [ "divide" ] }
        { \ ^ [ "power" ] }
        { \ [ [ "obama" ] }
        { \ ] [ "KFC" ] }
    } case ;

\ test-case-7 must-infer

[ "plus" ] [ \ + test-case-7 ] unit-test

! Some corner cases (no pun intended)
DEFER: corner-case-1

<< \ corner-case-1 2 [ + ] curry 1array [ case ] curry (( a -- b )) define-declared >>

[ t ] [ \ corner-case-1 optimized>> ] unit-test
[ 4 ] [ 2 corner-case-1 ] unit-test

[ 4 ] [ 2 2 [ + ] curry 1array case ] unit-test

: test-case-8 ( n -- )
    {
        { 1 [ "foo" ] }
    } case ;

[ 3 test-case-8 ]
[ object>> 3 = ] must-fail-with

[
    3 {
        { 1 [ "foo" ] }
    } case
] [ object>> 3 = ] must-fail-with

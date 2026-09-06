USING: arrays combinators combinators.smart compiler.tree
compiler.tree.builder continuations kernel locals math ranges
sequences stack-checker stack-checker.errors tools.test words ;
IN: compiler.tree.builder.tests

: inline-recursive ( -- ) inline-recursive ; inline recursive

{ t } [ \ inline-recursive build-tree [ #recursive? ] any? ] unit-test

: bad-recursion-1 ( a -- b )
    dup [ drop bad-recursion-1 5 ] [ ] if ;

[ \ bad-recursion-1 build-tree ] [ inference-error? ] must-fail-with

FORGET: bad-recursion-1

: bad-recursion-2 ( obj -- obj )
    dup [ dup first swap second bad-recursion-2 ] [ ] if ;

[ \ bad-recursion-2 build-tree ] [ inference-error? ] must-fail-with

FORGET: bad-recursion-2

: bad-bin ( a b -- ) 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] if ;

[ \ bad-bin build-tree ] [ inference-error? ] must-fail-with

FORGET: bad-bin

! #2879: a static call can consume an accumulator in an inline word's row.
:: static-row-call ( ... quot: ( n -- n' ) -- ... )
    quot call( n -- n' ) ; inline

[ \ static-row-call build-tree ] must-not-fail
{ 42 } [ 41 [ 1 + ] static-row-call ] unit-test
{ "below" 42 } [ "below" 41 [ 1 + ] static-row-call ] unit-test

: static-row-execute ( ... word -- ... ) execute( n -- n' ) ; inline
[ \ static-row-execute build-tree ] must-not-fail
{ -41 } [ 41 \ neg static-row-execute ] unit-test

: distinct-rows ( ..a -- ..b ) dup ; inline
[ \ distinct-rows build-tree ] must-not-fail
{ 7 7 } [ 7 distinct-rows ] unit-test

: input-row ( ..a -- ) drop ; inline
[ \ input-row build-tree ] must-not-fail

: output-row ( -- ..a ) 7 ; inline
[ \ output-row build-tree ] must-not-fail

:: quartets-find ( ... quot: ( max arr -- max' ) -- ... )
    3 [0..b] [
        :> a
        3 a - [0..b] [
            :> b
            3 a b + - [0..b] [
                :> c
                3 a b c + + - :> d
                a b c d 4array
                quot call( max arr -- max' )
            ] each
        ] each
    ] each ; inline

[ \ quartets-find build-tree ] must-not-fail
{ 20 } [ 0 [ drop 1 + ] quartets-find ] unit-test

: count-quartets ( -- n ) 0 [ drop 1 + ] quartets-find ;
{ 20 } [ count-quartets ] unit-test

! Row variables still constrain stack height, and are only honored for inline words.
: bad-row-height ( ... -- ... ) drop ; inline
[ \ bad-row-height build-tree ] [ effect-error? ] must-fail-with
FORGET: bad-row-height

: bad-non-inline-row ( ... -- ... ) 1 + ;
[ \ bad-non-inline-row build-tree ] [ effect-error? ] must-fail-with
FORGET: bad-non-inline-row

: bad-terminating-row ( ... -- * ) ; inline
[ \ bad-terminating-row build-tree ] [ effect-error? ] must-fail-with
FORGET: bad-terminating-row

: terminating-row ( ... -- * ) "stop" throw ; inline
[ \ terminating-row build-tree ] must-not-fail

! #140: monomorphic quotation parameters can be called without inlining.
: annotated-call ( x quot: ( x -- y ) -- y ) call ;
{ 42 } [ 41 [ 1 + ] annotated-call ] unit-test
{ f } [ \ annotated-call inline? ] unit-test
{ "below" 42 } [ "below" 41 [ 1 + ] annotated-call ] unit-test
[ 41 [ drop ] annotated-call ] [ wrong-values? ] must-fail-with

:: annotated-locals ( x quot: ( x -- y ) -- y ) x quot call ;
{ 42 } [ 41 [ 1 + ] annotated-locals ] unit-test

: annotated-curry ( x quot: ( x y -- z ) -- z )
    1 swap curry call ;
{ 42 } [ 41 [ + ] annotated-curry ] unit-test

: annotated-compose ( x quot: ( x -- y ) -- z )
    [ 1 + ] compose call ;
{ 42 } [ 40 [ 1 + ] annotated-compose ] unit-test

: annotated-outputs ( quot: ( x -- y z ) -- n ) outputs ;
{ 3 } [ [ dup dup ] annotated-outputs ] unit-test

:: annotated-choice ( x ? q1: ( a -- b ) q2: ( x -- y ) -- z )
    x ? [ q1 ] [ q2 ] if call ;
{ 42 } [ 41 t [ 1 + ] [ 1 - ] annotated-choice ] unit-test
{ 40 } [ 41 f [ 1 + ] [ 1 - ] annotated-choice ] unit-test

: annotated-if ( x ? q1: ( x -- y ) q2: ( x -- y ) -- z ) if ;
{ 42 } [ 41 t [ 1 + ] [ 1 - ] annotated-if ] unit-test
{ 40 } [ 41 f [ 1 + ] [ 1 - ] annotated-if ] unit-test

:: annotated-repeat ( n x quot: ( x -- x' ) -- y )
    n 0 > [ n 1 - x quot call quot annotated-repeat ] [ x ] if ;
{ 42 } [ 3 39 [ 1 + ] annotated-repeat ] unit-test

: missing-annotation ( x quot -- y ) call ;
[ \ missing-annotation build-tree ] [ unknown-macro-input? ] must-fail-with
FORGET: missing-annotation

: annotated-stopping ( quot: ( -- * ) -- * ) call ;
[ [ "stopped" throw ] annotated-stopping ] [ "stopped" = ] must-fail-with
[ [ ] annotated-stopping ] [ wrong-values? ] must-fail-with

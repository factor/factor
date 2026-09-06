USING: arrays compiler.tree compiler.tree.builder continuations
kernel locals math ranges sequences stack-checker
stack-checker.errors tools.test ;
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

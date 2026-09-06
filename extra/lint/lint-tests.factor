USING: accessors continuations io lint kernel math namespaces
sequences tools.test words ;
IN: lint.tests

! Don't write code like this
: lint1 ( obj -- ) [ "hi" print ] [ ] if ; ! when

{ { { lint1 { [ [ ] if ] } } } } [ \ lint1 lint-word ] unit-test

! : lint2 ( a b -- b a b ) dup -rot ; ! tuck

! [ { { lint2 { [ dup -rot ] } } } ] [ \ lint2 lint-word ] unit-test

: lint3 ( seq -- seq ) [ 0 swap nth 1 + ] map ;

{ { { lint3 { [ 0 swap nth ] } } } } [ \ lint3 lint-word ] unit-test

! #801: report needless annotations without rejecting valid recursion.
: unnecessary-recursion ( x -- y ) 1 + ; inline recursive
{ t } [ \ unnecessary-recursion unused-recursive? ] unit-test
{ f } [ \ lint3 unused-recursive? ] unit-test
{ t } [ \ unnecessary-recursion inline-recursive? ] unit-test

: countdown ( n -- )
    dup 0 > [ 1 - countdown ] [ drop ] if ; inline recursive
{ f } [ \ countdown unused-recursive? ] unit-test

DEFER: mutual-a
: mutual-b ( n -- )
    dup 0 > [ 1 - mutual-a ] [ drop ] if ; inline recursive
: mutual-a ( n -- )
    dup 0 > [ 1 - mutual-b ] [ drop ] if ; inline recursive
{ f } [ \ mutual-a unused-recursive? ] unit-test
{ f } [ \ mutual-b unused-recursive? ] unit-test

: unknown-input ( quot -- ) call ; inline recursive
{ f } [ \ unknown-input unused-recursive? ] unit-test
{ t } [
    error get-global
    \ unknown-input unused-recursive? drop
    error get-global eq?
] unit-test

FORGET: unknown-input

DEFER: generated-recursion
MACRO: recurse-again ( -- quot ) [ generated-recursion ] ;
: generated-recursion ( n -- )
    dup 0 > [ 1 - recurse-again ] [ drop ] if ; inline recursive
{ f } [ \ generated-recursion unused-recursive? ] unit-test

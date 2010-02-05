IN: stack-checker.transforms.tests
USING: sequences stack-checker.transforms tools.test math kernel
quotations stack-checker stack-checker.errors accessors
combinators words arrays classes classes.tuple macros ;

MACRO: compose-n ( n word -- quot' ) <repetition> >quotation ;

: compose-n-test ( a b c -- x ) 2 \ + compose-n ;

[ 6 ] [ 1 2 3 compose-n-test ] unit-test

TUPLE: color r g b ;

C: <color> color

: cleave-test ( color -- r g b )
    { [ r>> ] [ g>> ] [ b>> ] } cleave ;

{ 1 3 } [ cleave-test ] must-infer-as

[ 1 2 3 ] [ 1 2 3 <color> cleave-test ] unit-test

[ 1 2 3 ] [ 1 2 3 <color> \ cleave-test def>> call ] unit-test

: 2cleave-test ( a b -- c d e ) { [ 2array ] [ + ] [ - ] } 2cleave ;

[ { 1 2 } 3 -1 ] [ 1 2 2cleave-test ] unit-test

[ { 1 2 } 3 -1 ] [ 1 2 \ 2cleave-test def>> call ] unit-test

: spread-test ( a b c -- d e f ) { [ sq ] [ neg ] [ recip ] } spread ;

[ 16 -3 1/6 ] [ 4 3 6 spread-test ] unit-test

[ 16 -3 1/6 ] [ 4 3 6 \ spread-test def>> call ] unit-test

[ fixnum instance? ] must-infer

: bad-new-test ( -- obj ) V{ } new ;

[ bad-new-test ] must-infer

[ bad-new-test ] must-fail

! Corner case if macro expansion calls 'infer', found by Doug
DEFER: smart-combo ( quot -- )

\ smart-combo [ infer [ ] curry ] 1 define-transform

[ [ "a" "b" "c" ] smart-combo ] must-infer

[ [ [ "a" "b" ] smart-combo "c" ] smart-combo ] must-infer

: very-smart-combo ( quot -- ) smart-combo ; inline

[ [ "a" "b" "c" ] very-smart-combo ] must-infer

[ [ [ "a" "b" ] very-smart-combo "c" ] very-smart-combo ] must-infer

! Caveat found by Doug
MACRO: curry-folding-test ( quot -- )
    length \ drop <repetition> >quotation ;

{ 3 0 } [ [ 1 2 3 ] curry-folding-test ] must-infer-as
{ 3 0 } [ 1 [ 2 3 ] curry curry-folding-test ] must-infer-as
{ 3 0 } [ [ 1 2 ] 3 [ ] curry compose curry-folding-test ] must-infer-as

[ [ curry curry-folding-test ] infer ]
[ T{ unknown-macro-input f curry-folding-test } = ] must-fail-with

: member?-test ( a -- ? ) { 1 2 3 10 7 58 } member? ;

[ f ] [ 1.0 member?-test ] unit-test
[ t ] [ \ member?-test def>> first [ member?-test ] all? ] unit-test

! Macro expansion should throw its own type of error
: bad-macro ( -- ) ;

\ bad-macro [ "OOPS" throw ] 0 define-transform

[ [ bad-macro ] infer ] [ [ transform-expansion-error? ] [ error>> "OOPS" = ] [ word>> \ bad-macro = ] tri and and ] must-fail-with

MACRO: two-params ( a b -- c ) + 1quotation ;

[ [ 3 two-params ] infer ] [ T{ unknown-macro-input f two-params } = ] must-fail-with
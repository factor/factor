IN: inference.transforms.tests
USING: sequences inference.transforms tools.test math kernel
quotations inference accessors combinators words arrays
classes ;

: compose-n-quot <repetition> >quotation ;
: compose-n compose-n-quot call ;
\ compose-n [ compose-n-quot ] 2 define-transform
: compose-n-test 2 \ + compose-n ;

[ 6 ] [ 1 2 3 compose-n-test ] unit-test

[ 0 ] [ { } bitfield-quot call ] unit-test

[ 256 ] [ 1 { 8 } bitfield-quot call ] unit-test

[ 268 ] [ 3 1 { 8 2 } bitfield-quot call ] unit-test

[ 268 ] [ 1 { 8 { 3 2 } } bitfield-quot call ] unit-test

[ 512 ] [ 1 { { 1+ 8 } } bitfield-quot call ] unit-test

\ new must-infer

TUPLE: a-tuple x y z ;

: set-slots-test ( x y z -- )
    { set-a-tuple-x set-a-tuple-y } set-slots ;

\ set-slots-test must-infer

: set-slots-test-2
    { set-a-tuple-x set-a-tuple-x } set-slots ;

[ [ set-slots-test-2 ] infer ] must-fail

TUPLE: color r g b ;

C: <color> color

: cleave-test { [ r>> ] [ g>> ] [ b>> ] } cleave ;

{ 1 3 } [ cleave-test ] must-infer-as

[ 1 2 3 ] [ 1 2 3 <color> cleave-test ] unit-test

[ 1 2 3 ] [ 1 2 3 <color> \ cleave-test word-def call ] unit-test

: 2cleave-test { [ 2array ] [ + ] [ - ] } 2cleave ;

[ { 1 2 } 3 -1 ] [ 1 2 2cleave-test ] unit-test

[ { 1 2 } 3 -1 ] [ 1 2 \ 2cleave-test word-def call ] unit-test

: spread-test { [ sq ] [ neg ] [ recip ] } spread ;

[ 16 -3 1/6 ] [ 4 3 6 spread-test ] unit-test

[ 16 -3 1/6 ] [ 4 3 6 \ spread-test word-def call ] unit-test

[ fixnum instance? ] must-infer
